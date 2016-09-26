require 'test_helper'

module GraphQL
  module Client
    module Query
      class InlineFragmentTest < Minitest::Test
        def setup
          schema_string = File.read(fixture_path('merchant_schema.json'))
          @schema = GraphQLSchema.new(schema_string)
          @document = Document.new(@schema)
        end

        def test_resolver_type_is_the_type
          shop = @schema['Shop']
          inline_fragment = InlineFragment.new(shop, document: @document)

          assert_equal shop, inline_fragment.resolver_type
        end

        def test_to_query
          shop = @schema['Shop']

          inline_fragment = InlineFragment.new(shop, document: @document) do |f|
            f.add_field('name')
          end

          query_string = <<~QUERY
            ... on Shop {
              name
            }
          QUERY

          assert_equal query_string.chomp, inline_fragment.to_query
        end
      end
    end
  end
end