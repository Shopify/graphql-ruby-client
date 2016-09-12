module GraphQL
  module Client
    class ConnectionProxy
      include Enumerable

      def initialize(parent:, parent_field:, client:, field:)
        @parent = parent
        @parent_field = parent_field
        @client = client
        @schema = @client.schema
        @field = field
        @type = @field.base_type
        @objects = []
        @loaded = false
      end

      def create(attributes = {})
        input_block = ''
        attributes.each do |key, value|
          input_block << "#{key}: \"#{value}\"\n"
        end

        type = @type.node_type
        type_name = type.name
        fields = type.scalar_fields.names.join(',')

        type_name[0] = type_name[0].downcase

        mutation = "
          mutation {
            #{type_name}Create(
              input: {
                #{input_block}
              }
            ) {
              #{type_name} {
                #{fields}
              },
            userErrors {
              field,
              message
            }
          }
        }"

        request = Request.new(client: @client, type: @type)
        ObjectProxy.new(attributes: request.from_query(mutation).object[type_name], client: @client, field: @field)
      end

      def each
        fetch_page unless @loaded

        @objects.each do |node|
          yield ObjectProxy.new(attributes: node, client: @client, field: @field)
        end
      end

      def length
        entries.length
      end

      private

      def connection_query(after: nil)
        query_builder.connection_from_object(
          @parent.type,
          @parent.id,
          @field,
          after: after,
          per_page: @client.per_page
        )
      end

      def deep_find(hash, target_key)
        return hash[target_key] if hash.key?(target_key)

        hash.each do |_, value|
          result = deep_find(value, target_key) if value.is_a? Hash
          return result unless result.nil?
        end

        nil
      end

      def fetch_page
        @loaded = true

        initial_response = Request.new(client: @client).from_query(connection_query)
        edges = deep_find(initial_response.data, 'edges')

        response = initial_response
        @objects += edges.map { |edge| edge.fetch('node') }

        while next_page?(response.data)
          cursor = edges.last.fetch('cursor')
          response = Request.new(client: @client).from_query(connection_query(after: cursor))
          edges = deep_find(response.data, 'edges')

          @objects += edges.map { |edge| edge.fetch('node') }
        end
      end

      def next_page?(response_data)
        next_page = deep_find(response_data, 'hasNextPage')
        if next_page.nil?
          false
        else
          next_page
        end
      end

      def query_builder
        @query_builder ||= QueryBuilder.new(@schema)
      end
    end
  end
end
