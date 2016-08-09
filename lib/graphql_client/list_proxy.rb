module GraphQL
  module Client
    class ListProxy
      include Enumerable

      def initialize(parent:, client:, type:, field:)
        @parent = parent
        @client = client
        @type = type
        @field = field
        @objects = []

        @query = ListQuery.new(parent: @parent, field: @field, return_type: @type)
        fetch_results
      end

      def each
        @objects.each do |node|
          yield node
        end
      end

      def length
        entries.length
      end

      private

      def fetch_results
        query = @query.query
        response = Request.new(client: @client).from_query(query)
        @objects = find_list(response.data)
      end

      def find_list(hash)
        hash.each do |_key, value|
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
