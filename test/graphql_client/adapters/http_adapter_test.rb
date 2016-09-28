require 'test_helper'

module GraphQL
  module Client
    module Adapters
      class HTTPAdapterTest < Minitest::Test
        def test_request_builds_a_request
          config = Config.new(url: 'http://example.org')
          adapter = HTTPAdapter.new(config)

          stub_request(:post, 'http://example.org')
            .with(
              body: {
                query: 'query { shop }',
                variables: {},
                operation_name: nil
              }.to_json,
              headers: { 'Accept' => 'application/json' }
            )
            .to_return(body: { data: { id: 1 } }.to_json)

          adapter.request('query { shop }')
        end

        def test_send_request_builds_a_request_with_operation_name
          config = Config.new(url: 'http://example.org')
          adapter = HTTPAdapter.new(config)

          stub_request(:post, 'http://example.org')
            .with(
              body: {
                query: 'query shopQuery { shop }',
                variables: {},
                operation_name: 'shopQuery'
              }.to_json,
              headers: { 'Accept' => 'application/json' }
            )
            .to_return(body: { data: { id: 1 } }.to_json)

          adapter.request('query shopQuery { shop }', operation_name: 'shopQuery')
        end

        def test_send_request_returns_a_response_instance
          config = Config.new(url: 'http://example.org')
          adapter = HTTPAdapter.new(config)

          stub_request(:post, 'http://example.org')
            .with(
              body: {
                query: 'query { shop }',
                variables: {},
                operation_name: nil
              }.to_json,
              headers: { 'Accept' => 'application/json' }
            )
            .to_return(body: { data: { id: 1 } }.to_json)

          response = adapter.request('query { shop }')

          assert_instance_of Response, response
        end

        def test_send_request_raises_an_exception_on_net_http_error
          config = Config.new(url: 'http://example.org')
          adapter = HTTPAdapter.new(config)

          stub_request(:post, 'http://example.org')
            .with(
              body: {
                query: 'query { shop }',
                variables: {},
                operation_name: nil
              }.to_json,
              headers: { 'Accept' => 'application/json' }
            )
            .to_return(status: 400)

          assert_raises HTTPAdapter::NetworkError do
            adapter.request('query { shop }')
          end
        end
      end
    end
  end
end
