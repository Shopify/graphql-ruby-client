module GraphQL
  module Client
    class ObjectProxy
      attr_reader :id, :type

      def initialize(properties:, client:, type:)
        @id = properties['id']
        @client = client
        @properties = properties
        @type = type
      end

      def [](key)
        @properties[key]
      end

      def all(field)
        return all_from_connection(field) if @type.connections.key? field
        return all_from_list(field) if @type.lists.key? field
        nil
      end

      private

      def all_from_connection(field)
        connection_type = @type.connections[field]
        return_type_name = connection_type.gsub('Connection', '')
        return_type = @client.schema.types[return_type_name]
        ConnectionProxy.new(parent: self, client: @client, return_type: return_type, field: field)
      end

      def all_from_list(field)
        return_type_name = @type.lists[field]
        return_type = @client.schema.types[return_type_name]
        ListProxy.new(parent: self, client: @client, return_type: return_type, field: field)
      end
    end
  end
end
