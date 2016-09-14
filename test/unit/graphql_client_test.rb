require 'test_helper'

module GraphQL
  module Client
    class ClientTest < Minitest::Test
      def test_new_instantiates_an_HTTPClient
        schema_string = File.read(fixture_path('merchant_schema.json'))
        schema = GraphQLSchema.new(schema_string)

        client = Client.new(schema)

        assert_instance_of HTTPClient, client
      end

      def test_new_accepts_a_block_for_HTTPClient
        schema_string = File.read(fixture_path('merchant_schema.json'))
        schema = GraphQLSchema.new(schema_string)

        url = URI('http://example.com')

        client = Client.new(schema) do
          configure do |c|
            c.url = url
          end
        end

        assert_equal url, client.config.url
      end
    end
  end
end
