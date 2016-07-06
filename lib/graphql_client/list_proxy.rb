module GraphQL
  module Client
    class ListProxy
      include Enumerable

      def initialize(parent:, client:, return_type:, field:)
        @parent = parent
        @client = client
        @return_type = return_type
        @field = field
        @objects = []

        @query = ListQuery.new(parent: @parent, field: @field, return_type: @return_type)
        fetch_results
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

      private

      def fetch_results
        query = @query.query
        response = Request.new(client: @client).from_query(query)
        @objects = find_list(response.data)
      end

      def find_list(hash)
        hash.each do |key, value|
          return value if value.is_a? Array

          if value.is_a? Hash
            result = find_list(value)
            return result unless result.nil?
          end
        end

        nil
      end
    end
  end
end
