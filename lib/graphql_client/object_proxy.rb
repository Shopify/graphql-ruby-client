module GraphQL
  module Client
    class ObjectProxy
      attr_reader :attributes, :field, :id, :parent, :type

      def initialize(*fields, field:, client:, parent: nil, data: {}, includes: {}, **arguments)
        @fields = fields.map(&:to_s)
        @field = field
        @id = arguments[:id]
        @client = client
        @type = type
        @dirty_attributes = Set.new
        @type = @field.base_type
        @parent = parent
        @data = data
        @includes = includes
        @loaded = !@data.empty?
        @arguments = arguments

        define_field_accessors
        define_connections_accessors
      end

      def destroy
        mutation = Query::MutationDocument.new(@client.schema) do |m|
          m.add_field("#{base_node_type_name}Delete", input: { id: id }) do |field|
            field.add_field('userErrors') do |errors|
              errors.add_fields('field', 'message')
            end
          end
        end

        @client.query(mutation)
      end

      def add_nested_query_fields(query)
        query = @parent.add_nested_query_fields(query) if @parent
        query.add_field(@field.name)
      end

      def field_name
        if connection?
          base_node_type.name.downcase
        else
          field.name
        end
      end

      def load
        response = if @id
          @client.query(object_query)
        else
          raise "Object of type #{type.name} requires a selection set" if @fields.empty?
          document = Query::Document.new(@client.schema)
          query_root = document.add_query
          field = add_nested_query_fields(query_root)

          field.arguments = @arguments if @arguments
          field.add_field('id') if @type.fields.field? 'id'
          field.add_fields(*@fields)

          @client.query(query_root)
        end

        @data = response_object(response)
        @loaded = true
      end

      def save
        input = @dirty_attributes.each_with_object({}) do |name, hash|
          hash[name] = @data[name]
        end

        mutation = Query::MutationDocument.new(@client.schema) do |m|
          m.add_field("#{base_node_type_name}Update", input: input.merge(id: id)) do |field|
            field.add_field('userErrors') do |errors|
              errors.add_fields('field', 'message')
            end
          end
        end

        @dirty_attributes.clear
        @client.query(mutation)
      end

      def query_path
        [].tap do |fields|
          fields << parent.field_name if parent
          fields << field_name
        end.flatten
      end

      private

      # TODO: 💩
      def connection?
        type.respond_to?(:node_type)
      end

      # TODO: 💩
      def base_node_type
        @base_node_type ||= connection? ? type.node_type : type
      end

      # TODO: 💩
      def base_node_type_name
        @base_node_type_name ||= base_node_type.name.dup.tap { |s| s[0] = s[0].downcase }
      end

      def define_connections_accessors
        base_node_type.connection_fields.each do |name, field|
          define_singleton_method(underscore(name)) do |*fields, **arguments|
            if @includes.empty?
              ConnectionProxy.new(
                *fields,
                client: @client,
                field: field,
                includes: @includes,
                parent: self,
                parent_field: @field,
                **arguments
              )
            else
              ConnectionProxy.new(
                *fields,
                client: @client,
                data: @data[name],
                field: field,
                includes: @includes,
                parent: self,
                parent_field: @field,
                **arguments
              )
            end
          end
        end
      end

      def define_field_accessors
        base_node_type.object_fields.each do |name, field|
          underscored_name = underscore(name)

          define_singleton_method(underscored_name) do |*fields, **arguments|
            if field.list?
              @data[name.to_s].map do |item_data|
                ObjectProxy.new(
                  *fields,
                  client: @client,
                  data: item_data,
                  field: field,
                  parent: self,
                  **arguments
                )
              end
            else
              ObjectProxy.new(
                *fields,
                client: @client,
                field: field,
                parent: self,
                **arguments
              )
            end
          end
        end

        base_node_type.scalar_fields.each do |name, _field|
          underscored_name = underscore(name)

          define_singleton_method(underscored_name) do
            load unless @loaded
            @data[name]
          end

          define_singleton_method("#{underscored_name}=") do |value|
            @data[name] = value
            @dirty_attributes.add(name)
          end
        end
      end

      def object_query
        Query::QueryDocument.new(@client.schema) do |q|
          q.add_field(base_node_type_name, id: @id) do |field|
            field.add_fields(*base_node_type.scalar_fields.names)
          end
        end
      end

      def response_object(response)
        response.data.dig(*query_path)
      end

      def underscore(name)
        name
          .gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end
    end
  end
end
