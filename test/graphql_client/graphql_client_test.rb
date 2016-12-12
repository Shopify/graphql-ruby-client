require 'test_helper'

module GraphQL
  module Client
    class ClientTest < Minitest::Test
      TestAdapter = Struct.new(:config) do
        def request(_query_string)
          Response.new('{ "data": { } }')
        end
      end

      def test_dump_schema_writes_a_schema_file_from_introspection_query
        adapter = TestAdapter.new(Config.new)

        Tempfile.create('temp_schema.json') do |f|
          Client.dump_schema(f, adapter: adapter)

          assert_equal(JSON.pretty_generate(data: {}), File.read(f))
        end
      end

      def test_new_instantiates_base
        schema_string = File.read(fixture_path('merchant_schema.json'))
        schema = GraphQLSchema.new(schema_string)

        client = Client.new(schema)

        assert_instance_of Base, client
      end

      def test_new_accepts_a_block_for_httpclient
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
