module GraphQL
  module Client
    class ObjectProxy
      attr_reader :attributes, :id, :type

      def initialize(attributes: {}, id: nil, client:, type:)
        @attributes = attributes
        @id = id
        @client = client
        @type = type
        @dirty_attributes = Set.new
        @loaded = !@attributes.empty?

        define_field_accessors
        define_connections_accessors
      end

      def destroy
        type_name = type.node_type.name
        type_name[0] = type_name[0].downcase

        mutation = "
          mutation {
            #{type_name}Delete(
              input: {
                id: \"#{id}\"
              }
            ) {
              userErrors {
                field,
                message
              }
            }
          }"

        request = Request.new(client: @client, type: @type)
        request.from_query(mutation)
      end

      def load
        request = Request.new(client: @client, type: @type)

        @attributes = if @id
          request.find(@id).object
        else
          request.simple_find(@type.name).object
        end

        @loaded = true
      end

      def save
        type_name = if @type.respond_to?(:node_type)
          @type.node_type.name
        else
          @type.name
        end

        type_name[0] = type_name[0].downcase

        attributes_block = ''
        @dirty_attributes.each do |name|
          attributes_block << "#{name}: \"#{@attributes[name]}\"\n"
        end

        mutation = "
          mutation {
            #{type_name}Update(
              input: {
                id: \"#{id}\"
                #{attributes_block}
              }
            ) {
              userErrors {
                field,
                message
              }
            }
          }"

        @dirty_attributes.clear
        request = Request.new(client: @client, type: @type)
        request.from_query(mutation)
      end

      private

      def define_connections_accessors
        accessors = if type.name.end_with? 'Connection'
          type.node_type.fields.connections
        else
          type.fields.connections
        end

        accessors.each do |name, field|
          define_singleton_method(underscore(name)) do
            ConnectionProxy.new(parent: self, client: @client, type: field.base_type, field: name)
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
