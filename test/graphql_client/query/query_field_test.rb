require 'test_helper'

module GraphQL
  module Client
    module Query
      class QueryFieldTest < Minitest::Test
        def setup
          schema_string = File.read(fixture_path('merchant_schema.json'))
          @schema = GraphQLSchema.new(schema_string)
          @document = Document.new(@schema)
        end

        def test_validates_arguments
          field = @schema.query_root.fields.fetch('shop')

          assert_raises QueryField::INVALID_ARGUMENTS do
            QueryField.new(field, document: @document, arguments: { id: 2 })
          end
        end

        def test_add_field_creates_field_and_adds_to_selection_set
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, arguments: {})

          query_field.add_field('name')

          assert_equal 1, query_field.selection_set.size
        end

        def test_add_fields_creates_multiple_selection_set
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, arguments: {})

          query_field.add_fields('id', 'name')

          assert_equal 2, query_field.selection_set.size
        end

        def test_add_field_uses_as_alias_name
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, arguments: {}, as: 'myshop')

          query_field.add_field('name')

          query_string = <<~QUERY
            myshop: shop {
              name
            }
          QUERY

          assert_equal query_string.chomp, query_field.to_query
        end

        def test_resolver_type_is_the_fields_base_type
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, arguments: {})

          assert_equal field.base_type, query_field.resolver_type
        end

        def test_to_query_is_the_graphql_query_string
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, arguments: {})

          assert_equal 'shop', query_field.to_query
        end

        def test_to_query_includes_the_selection_set_selection_set
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, arguments: {})

          query_field.add_field('name')

          query_string = <<~QUERY
            shop {
              name
            }
          QUERY

          assert_equal query_string.chomp, query_field.to_query
        end

        def test_to_query_includes_arguments
          field = @schema.query_root.fields.fetch('shop')

          shop = QueryField.new(field, document: @document)
          shop.add_field('name')

          shop.add_connection('products', first: 5, after: 'cursor') do |products|
            products.add_field('title')
          end

          query_string = <<~QUERY
            shop {
              name
              products(first: 5, after: "cursor") {
                edges {
                  cursor
                  node {
                    id
                    title
                  }
                }
                pageInfo {
                  hasPreviousPage
                  hasNextPage
                }
              }
            }
          QUERY

          assert_equal query_string.chomp, shop.to_query
        end
      end
    end
  end
end
