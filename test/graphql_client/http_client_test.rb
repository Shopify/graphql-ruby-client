require 'test_helper'

module GraphQL
  module Client
    class BaseTest < Minitest::Test
      def test_configure_yields_the_config
        schema_string = File.read(fixture_path('merchant_schema.json'))
        schema = GraphQLSchema.new(schema_string)

        client = Base.new(schema)

        client.configure do |c|
          assert_equal c, client.config
        end
      end

      def test_query_calls_adapter_request_with_query_builder_instance
        schema_string = File.read(fixture_path('merchant_schema.json'))
        schema = GraphQLSchema.new(schema_string)
        config = Config.new(url: 'http://example.com')

        query = Minitest::Mock.new
        query.expect(:to_query, 'query shopQuery { shop }')

        adapter = Minitest::Mock.new
        adapter.expect(:request, nil, ['query shopQuery { shop }', operation_name: 'shopQuery'])

        client = Base.new(schema, config: config, adapter: adapter)
        client.query(query, operation_name: 'shopQuery')

        query.verify
      end

      def test_raw_query_calls_adapter_request_with_query_string
        schema_string = File.read(fixture_path('merchant_schema.json'))
        schema = GraphQLSchema.new(schema_string)
        config = Config.new(url: 'http://example.com')

        adapter = Minitest::Mock.new
        adapter.expect(:request, nil, ['query { shop }', operation_name: nil])

        client = Base.new(schema, config: config, adapter: adapter)
        client.raw_query('query { shop }')

        adapter.verify
      end
    end
  end
end
