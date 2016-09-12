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
        type_name = type.node_type.name.dup
        type_name[0] = type_name[0].downcase

        mutation = Query::MutationOperation.new(@client.schema) do |q|
          q.add_field("#{type_name}Delete", input: { id: id }) do |field|
            field.add_field('userErrors') do |errors|
              errors.add_fields('field', 'message')
            end
          end
        end

        request = Request.new(client: @client, type: @type)
        request.from_query(mutation.to_query)
      end

      def load
        request = Request.new(client: @client, type: @type)

        @attributes = if @id
          request.find(@id).object
        else
          raise "Object of type #{@type.name} requires a selection set" if @fields.empty?
          request.for_field(@field, fields: @fields).object
        end

        @loaded = true
      end

      def save
        type_name = if @type.respond_to?(:node_type)
          @type.node_type.name
        else
          @type.name
        end.dup

        type_name[0] = type_name[0].downcase

        input = @dirty_attributes.each_with_object({}) do |name, hash|
          hash[name] = @attributes[name]
        end

        mutation = Query::MutationOperation.new(@client.schema) do |q|
          q.add_field("#{type_name}Update", input: input.merge(id: id)) do |field|
            field.add_field('userErrors') do |errors|
              errors.add_fields('field', 'message')
            end
          end
        end

        @dirty_attributes.clear
        request = Request.new(client: @client, type: @type)
        request.from_query(mutation.to_query)
      end

      private

      def define_connections_accessors
        accessors = if type.name.end_with? 'Connection'
          type.node_type.connection_fields
        else
          type.connection_fields
        end

        accessors.each do |name, field|
          define_singleton_method(underscore(name)) do |**arguments|
            ConnectionProxy.new(parent: self, parent_field: @field, client: @client, field: field, **arguments)
          end
        end
      end

      def define_field_accessors
        accessors = if type.name.end_with? 'Connection'
          type.node_type.scalar_fields + type.node_type.object_fields
        else
          type.scalar_fields + type.object_fields
        end

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
