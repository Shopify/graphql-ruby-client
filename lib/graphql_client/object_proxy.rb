module GraphQL
  module Client
    class ObjectProxy
      attr_reader :attributes, :id, :type

      def initialize(attributes: {}, id: nil, client:, field:, fields: [])
        raise "No strings allowed" if field.is_a? String
        @attributes = attributes
        @id = id
        @client = client
        @type = type
        @dirty_attributes = Set.new
        @loaded = !@attributes.empty?
        @field = field
        @type = @field.base_type
        @fields = fields

        define_field_accessors
        define_connections_accessors
      end

      def destroy
        mutation = Query::MutationOperation.new(@client.schema) do |q|
          q.add_field("#{base_node_type_name}Delete", input: { id: id }) do |field|
            field.add_field('userErrors') do |errors|
              errors.add_fields('field', 'message')
            end
          end
        end

        @client.query(mutation)
      end

      def load
        response = if @id
          @client.query(object_query(@id))
        else
          raise "Object of type #{type.name} requires a selection set" if @fields.empty?

          query = Query::QueryOperation.new(@client.schema) do |q|
            q.add_field(@field.name) do |query_field|
              query_field.add_fields(*@fields)
            end
          end

          @client.query(query)
        end

        @attributes = response_object(response)
        @loaded = true
      end

      def save
        input = @dirty_attributes.each_with_object({}) do |name, hash|
          hash[name] = @attributes[name]
        end

        mutation = Query::MutationOperation.new(@client.schema) do |q|
          q.add_field("#{base_node_type_name}Update", input: input.merge(id: id)) do |field|
            field.add_field('userErrors') do |errors|
              errors.add_fields('field', 'message')
            end
          end
        end

        @dirty_attributes.clear
        @client.query(mutation)
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
          define_singleton_method(underscore(name)) do |**arguments|
            ConnectionProxy.new(parent: self, parent_field: @field, client: @client, field: field, **arguments)
          end
        end
      end

      def define_field_accessors
        accessors = base_node_type.scalar_fields + base_node_type.object_fields

        accessors.each do |name, _field_type|
          underscored_name = underscore(name)

          define_singleton_method(underscored_name) do
            load unless @loaded
            @attributes[name]
          end

          define_singleton_method("#{underscored_name}=") do |value|
            @attributes[name] = value
            @dirty_attributes.add(name)
          end
        end
      end

      def object_query(id)
        Query::QueryOperation.new(@client.schema) do |q|
          q.add_field(base_node_type_name, id: id) do |field|
            field.add_fields(*base_node_type.scalar_fields.names)
          end
        end
      end

      def response_object(response)
        object = response.data.keys.first
        response.data.fetch(object)
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
