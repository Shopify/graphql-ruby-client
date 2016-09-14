require 'test_helper'

module GraphQL
  module Client
    class ConfigTest < Minitest::Test
      def test_send_request_builds_a_request
        config = Config.new(url: 'http://example.org')
        req = Request.new(config)

        stub_request(:post, 'http://example.org')
          .with(
            body: "{\"query\":\"query { shop }\",\"variables\":{}}",
            headers: { 'Accept' => 'application/json' }
          )
          .to_return(body: "{\"data\":{\"id\":1}}")

        req.send_request('query { shop }')
      end

      def test_send_request_returns_a_response_instance
        config = Config.new(url: 'http://example.org')
        req = Request.new(config)

        stub_request(:post, 'http://example.org')
          .with(
            body: "{\"query\":\"query { shop }\",\"variables\":{}}",
            headers: { 'Accept' => 'application/json' }
          )
          .to_return(body: "{\"data\":{\"id\":1}}")

        response = req.send_request('query { shop }')

        assert_instance_of Response, response
      end

      def test_send_request_raises_an_exception_on_net_http_error
        config = Config.new(url: 'http://example.org')
        req = Request.new(config)

        stub_request(:post, 'http://example.org')
          .with(
            body: "{\"query\":\"query { shop }\",\"variables\":{}}",
            headers: { 'Accept' => 'application/json' }
          )
          .to_return(status: 400)

        assert_raises NetworkError do
          req.send_request('query { shop }')
        end
      end
    end
  end
end
