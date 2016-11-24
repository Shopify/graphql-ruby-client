module GraphQL
  module Client
    class Base
      attr_reader :adapter, :config, :schema

      def initialize(schema, config: nil, adapter: nil, &block)
        @config = config || Config.new
        @schema = schema
        @adapter = adapter || Adapters::HTTPAdapter.new(@config)

        instance_eval(&block) if block_given?
      end

      def build_query
        query = Query::Document.new(@schema)

        if block_given?
          yield query
        else
          query
        end
      end

      def configure
        yield @config
      end

      def query(query, operation_name: nil, variables: {})
        response = adapter.request(query.to_query, operation_name: operation_name, variables: variables)
        GraphObject.new(data: response.data, query: query)
      end

      def raw_query(query_string, operation_name: nil, variables: {})
        adapter.request(query_string, operation_name: operation_name, variables: variables)
      end
    end
  end
end
