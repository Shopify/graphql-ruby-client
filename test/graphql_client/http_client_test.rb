require 'test_helper'

module GraphQL
  module Client
    class BaseTest < Minitest::Test
      def test_configure_yields_the_config
        client = Base.new(schema_fixture('schema.json'))

        client.configure do |c|
          assert_equal c, client.config
        end
      end

      def test_query_calls_adapter_request_with_query_builder_instance_and_creates_a_graph_object
        config = Config.new(url: 'http://example.com')

        query = Minitest::Mock.new
        query.expect(:to_query, 'query shopQuery { shop }')

        adapter = Minitest::Mock.new
        adapter.expect(:request, Response.new('{}'), [
          'query shopQuery { shop }',
          operation_name: 'shopQuery',
          variables: {}
        ])

        mock = Minitest::Mock.new
        mock.expect(:call, nil, [data: nil, query: query])

        GraphObject.stub(:new, mock) do
          client = Base.new(schema_fixture('schema.json'), config: config, adapter: adapter)
          client.query(query, operation_name: 'shopQuery')

          mock.verify
          query.verify
        end
      end

      def test_raw_query_calls_adapter_request_with_query_string
        config = Config.new(url: 'http://example.com')

        adapter = Minitest::Mock.new
        adapter.expect(:request, Response.new('{}'), ['query { shop }', operation_name: nil, variables: {}])

        client = Base.new(schema_fixture('schema.json'), config: config, adapter: adapter)
        client.raw_query('query { shop }')

        adapter.verify
      end

      def test_raw_query_with_extensions_calls_adapter_request_with_query_string
        config = Config.new(url: 'http://example.com')

        adapter = Minitest::Mock.new
        adapter.expect(:request, Response.new('{}'), ['query { shop }', operation_name: nil, variables: {}])

        client = Base.new(schema_fixture('schema.json'), config: config, adapter: adapter)
        client.raw_query_with_extensions('query { shop }')

        adapter.verify
      end

      def test_raw_query_with_extensions_returns_response_objects_for_data_and_extensions
        config = Config.new(url: 'http://example.com')

        response = Minitest::Mock.new
        response.expect(:data, { 'name' => 'shop' })
        response.expect(:extensions, { 'foo' => 'bar' })

        client = Base.new(schema_fixture('schema.json'), config: config, adapter: AdapterStub.new(response))
        data, extensions = client.raw_query_with_extensions('query { shop }')

        assert_equal 'shop', data.name
        assert_equal 'bar', extensions.foo
        response.verify
      end
    end

    class AdapterStub
      def initialize(request)
        @request = request
      end

      def request(*)
        @request
      end
    end
  end
end
