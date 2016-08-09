module GraphQL
  module Client
    class ObjectProxy
      attr_reader :id, :type, :attributes

      def initialize(attributes:, client:, type:)
        @id = attributes['id']
        @client = client
        @attributes = attributes
        @dirty_attributes = Set.new
        @type = type
      end

      def method_missing(name, *arguments, &block)
        field = name.to_s
        return all_from_connection(field) if @type.connections.key? field
        return all_from_list(field) if @type.lists.key? field

        if field.end_with? '='
          field = field.chomp('=')
          @attributes[field] = arguments.first
          @dirty_attributes.add(field)
        else
          @attributes[field]
        end
      end

      def save
        type_name = @type.name.camelize(:lower)
        fields = @type.primitive_fields.keys.join(',')

        attributes_block = ''
        @dirty_attributes.each do |name|
          attributes_block << "#{name}: \"#{@attributes[name]}\"\n"
        end

        mutation = "
          mutation {
            #{type_name}Update(
              input: {
                id: \"#{@id}\"
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
        type_name = @type.name.camelize(:lower)

        mutation = "
          mutation {
            #{type_name}Delete(
              input: {
                id: \"#{@id}\"
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

      def all_from_connection(field)
        connection_type = @type.connections[field]
        return_type_name = connection_type.gsub('Connection', '')
        return_type = @client.schema.types[return_type_name]
        ConnectionProxy.new(parent: self, client: @client, type: return_type, field: field)
      end

      def all_from_list(field)
        return_type_name = @type.lists[field]
        return_type = @client.schema.types[return_type_name]
        ListProxy.new(parent: self, client: @client, type: return_type, field: field)
      end
    end
  end
end
