require 'test_helper'

module GraphQL
  module Client
    class ResponseTest < Minitest::Test
      def test_initialize_parses_json
        body = { data: { id: 1 } }
        response = Response.new(body.to_json)

        assert_equal({ 'data' => { 'id' => 1 } }, response.body)
        assert_equal({ 'id' => 1 }, response.data)
      end

      def test_initialize_sets_errors
        body = {
          data: { id: 1 },
          errors: [
            { message: 'error' }
          ]
        }

        response = Response.new(body.to_json)

        assert_equal [{ 'message' => 'error' }], response.errors
      end

      def test_initialize_sets_errors_default
        body = { data: { id: 1 } }
        response = Response.new(body.to_json)

        assert_equal [], response.errors
      end

      def test_initialize_sets_extensions
        body = {
          data: { id: 1 },
          extensions: [
            { foo: 'bar' }
          ]
        }

        response = Response.new(body.to_json)

        assert_equal [{ 'foo' => 'bar' }], response.extensions
      end

      def test_initialize_sets_extensions_default
        body = { data: { id: 1 } }
        response = Response.new(body.to_json)

        assert_equal [], response.extensions
      end

      def test_initialize_raises_error_if_response_contains_errors_without_data
        assert_raises ResponseError do
          body = { errors: [{}] }
          Response.new(body.to_json)
        end

        assert_raises ResponseError do
          body = { data: nil, errors: [{}] }
          Response.new(body.to_json)
        end
      end
    end
  end
end
