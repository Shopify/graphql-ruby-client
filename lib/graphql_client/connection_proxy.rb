module GraphQL
  module Client
    class ConnectionProxy
      include Enumerable

      def initialize(parent:, client:, return_type:, field:)
        @parent = parent
        @client = client
        @return_type = return_type
        @field = field
        @objects = []

        @query = ConnectionQuery.new(parent: @parent, field: @field, return_type: @return_type, per_page: @client.per_page)
        fetch_page
      end

      def fetch_page
        query = @query.query
        initial_response = Request.new(client: @client).from_query(query)

        edges = deep_find(initial_response.data, 'edges')

        response = initial_response
        @objects = @objects + edges.map{|edge| edge['node']}
        while(has_next_page?(response.data))
          cursor = edges.last['cursor']
          response = Request.new(client: @client).from_query(@query.query(after: cursor))
          edges = deep_find(response.data, 'edges')
          @objects = @objects + edges.map{|edge| edge['node']}
        end
      end

      def deep_find(hash, target_key)
        return hash[target_key] if hash.key?(target_key)
        hash.each do |key, value|
          result = deep_find(value, target_key) if value.is_a? Hash
          return result unless result.nil?
        end

        nil
      end

      def has_next_page?(response_data)
        next_page = deep_find(response_data, 'hasNextPage')
        if next_page.nil?
          false
        else
          next_page
        end
      end

      def [](index)
        entries[index]
      end

      def length
        entries.length
      end

      def each(&block)
        @objects.each do |node|
          yield node
        end
      end
    end
  end
end
