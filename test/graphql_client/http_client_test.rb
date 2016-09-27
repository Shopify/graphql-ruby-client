require 'test_helper'

module GraphQL
  module Client
    class HTTPClientTest < Minitest::Test
      def test_configure_yields_the_config
        schema_string = File.read(fixture_path('merchant_schema.json'))
        schema = GraphQLSchema.new(schema_string)

        client = HTTPClient.new(schema)

        client.configure do |c|
          assert_equal c, client.config
        end
      end

      def test_query_creates_and_sends_a_request_from_a_query_object
        schema_string = File.read(fixture_path('merchant_schema.json'))
        schema = GraphQLSchema.new(schema_string)
        config = Config.new(url: 'http://example.com')

        query = Minitest::Mock.new
        query.expect(:to_query, 'query shopQuery { shop }')

        req = Minitest::Mock.new
        req.expect(:send_request, nil, ['query shopQuery { shop }', operation_name: 'shopQuery'])

        Request.stub(:new, req) do
          client = HTTPClient.new(schema, config: config)
          client.query(query, operation_name: 'shopQuery')

          query.verify
          req.verify
        end
      end

      def test_raw_query_creates_and_sends_a_request_from_a_query_string
        schema_string = File.read(fixture_path('merchant_schema.json'))
        schema = GraphQLSchema.new(schema_string)
        config = Config.new(url: 'http://example.com')

        req = Minitest::Mock.new
        req.expect(:send_request, nil, ['query { shop }', operation_name: nil])

        Request.stub(:new, req) do
          client = HTTPClient.new(schema, config: config)
          client.raw_query('query { shop }')

          req.verify
        end
      end
    end
  end
end
