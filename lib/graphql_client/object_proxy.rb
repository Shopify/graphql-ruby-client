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
        define_lists_accessors
        define_connections_accessors
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
        type_name = @type.camel_case_name

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

      def destroy
        type_name = type.camel_case_name

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

      private

      def define_connections_accessors
        type.connections.each do |name, type_name|
          name = underscore(name)

          define_singleton_method(name) do
            return_type_name = type_name.gsub('Connection', '')
            return_type = @client.schema.type(return_type_name)
            ConnectionProxy.new(parent: self, client: @client, type: return_type, field: name)
          end
        end
      end

      def define_field_accessors
        type.fields.each do |name, _field_type|
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

      def define_lists_accessors
        type.lists.each do |name, type_name|
          name = underscore(name)

          define_singleton_method(name) do
            return_type = @client.schema.type(type_name)
            ListProxy.new(parent: self, client: @client, type: return_type, field: name)
          end
        end
      end

      def underscore(name)
        name
          .gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
          .gsub(/([a-z\d])([A-Z])/,'\1_\2')
          .tr('-', '_')
          .downcase
      end
    end
  end
end
