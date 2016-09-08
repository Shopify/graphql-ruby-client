module GraphQL
  module Client
    class ConnectionProxy
      include Enumerable

      def initialize(parent:, client:, type:, field:)
        @parent = parent
        @client = client
        @type = type
        @field = field
        @objects = []
        @loaded = false

        @query = ConnectionQuery.new(
          parent: @parent,
          field: @field,
          return_type: @type,
          client: @client
        )
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
        ObjectProxy.new(type: @type, attributes: request.from_query(mutation).object[type_name], client: @client)
      end

      def each
        fetch_page unless @loaded

        @objects.each do |node|
          yield ObjectProxy.new(attributes: node, client: @client, type: @type)
        end
      end

      def length
        entries.length
      end

      private

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
        query = @query.query
        initial_response = Request.new(client: @client).from_query(query)

        edges = deep_find(initial_response.data, 'edges')

        response = initial_response
        @objects += edges.map { |edge| edge['node'] }
        while next_page?(response.data)
          cursor = edges.last['cursor']
          response = Request.new(client: @client).from_query(@query.query(after: cursor))
          edges = deep_find(response.data, 'edges')
          @objects += edges.map { |edge| edge['node'] }
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
    end
  end
end
