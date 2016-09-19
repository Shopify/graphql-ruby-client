require 'test_helper'

module GraphQL
  module Client
    class ResponseTest < Minitest::Test
      def test_initialize_parses_json
        response = Response.new("{\"data\":{\"id\":1}}")
        assert_equal({ 'id' => 1 }, response.data)
      end

      def test_initialize_raises_error_if_response_contains_errors
        assert_raises Response::MalformedError do
          Response.new("{\"errors\":{\"id\":1}}")
        end
      end
    end
  end
end
