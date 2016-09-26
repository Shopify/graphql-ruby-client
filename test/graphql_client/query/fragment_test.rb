require 'test_helper'

module GraphQL
  module Client
    module Query
      class FragmentTest < Minitest::Test
        def setup
          schema_string = File.read(fixture_path('merchant_schema.json'))
          @schema = GraphQLSchema.new(schema_string)
          @document = Document.new(@schema)
        end

        def test_resolver_type_is_the_type
          shop = @schema['Shop']
          fragment = Fragment.new('shopFields', shop, document: @document)

          assert_equal shop, fragment.resolver_type
        end

        def test_to_definition
          shop = @schema['Shop']
          fragment = Fragment.new('shopFields', shop, document: @document)
          fragment.add_field('name')

          definition_string = <<~QUERY
            fragment shopFields on Shop {
              name
            }
          QUERY

          assert_equal definition_string, fragment.to_definition
        end

        def test_to_query_is_the_fragment_spread
          shop = @schema['Shop']

          fragment = Fragment.new('shopFields', shop, document: @document) do |f|
            f.add_field('name')
          end

          assert_equal '...shopFields', fragment.to_query
        end
      end
    end
  end
end
