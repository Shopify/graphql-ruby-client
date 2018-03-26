# frozen_string_literal: true

module GraphQL
  module Client
    class Base
      attr_reader :adapter, :config, :schema

      def initialize(schema, config: nil, adapter: nil, &block)
        @config = config || Config.new
        @schema = load_schema(schema)
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
        raw_query_with_extensions(query_string, operation_name: operation_name, variables: variables)[0]
      end

      def raw_query_with_extensions(query_string, operation_name: nil, variables: {})
        response = adapter.request(query_string, operation_name: operation_name, variables: variables)
        [ResponseObject.new(response.data), ResponseObject.new(response.extensions)]
      end

      private

      def load_schema(schema)
        case schema
        when Pathname
          schema_string = JSON.parse(File.read(schema))
          GraphQLSchema.new(schema_string)
        else
          GraphQLSchema.new(schema)
        end
      end
    end
  end
end
