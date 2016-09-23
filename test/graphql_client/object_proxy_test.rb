require 'test_helper'

module GraphQL
  module Client
    class ObjectProxyTest < Minitest::Test
      def setup
        schema_string = File.read(fixture_path('merchant_schema.json'))
        schema = GraphQLSchema.new(schema_string)
        @client = HTTPClient.new(schema)
      end

      def test_query_path
        assert_equal ['shop'], @client.shop.query_path
      end

      def test_nested_query_path
        billing_address = @client.shop.billing_address
        assert_equal ['shop', 'billingAddress'], billing_address.query_path
      end
    end
  end
end
