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

        def test_add_arguments_merges_new_arguments_with_existing_ones
          shop = @schema.query_root.fields.fetch('shop')
          field = shop.base_type.fields.fetch('products')
          query_field = QueryField.new(field, document: @document, arguments: { first: 5 })

          query_field.add_arguments(first: 10, after: 'cursor')

          first_arg = Argument.new(10)
          after_arg = Argument.new('cursor')

          assert_equal({ first: first_arg, after: after_arg }, query_field.arguments)
        end

        def test_add_field_creates_field_and_adds_to_selection_set
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, arguments: {})

          name = query_field.add_field('name')

          assert_equal({ 'name' => name }, query_field.selection_set.fields)
        end

        def test_add_field_does_not_add_duplicate_fields
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, arguments: {})

          query_field.add_field('name')
          new_name = query_field.add_field('name')

          assert_equal({ 'name' => new_name }, query_field.selection_set.fields)
        end

        def test_add_field_allows_multiple_fields_of_same_type_with_aliases
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, arguments: {})

          name = query_field.add_field('name')
          myname = query_field.add_field('name', as: 'myname')

          assert_equal({ 'name' => name, 'myname' => myname }, query_field.selection_set.fields)
        end

        def test_add_fields_creates_multiple_fields
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, arguments: {})

          query_field.add_fields('id', 'name')

          assert_equal %w(id name), query_field.selection_set.fields.keys
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

        def test_name_returns_alias_if_set
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document, as: 'myshop')

          assert_equal 'myshop', query_field.name
        end

        def test_name_defaults_to_field_name
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, document: @document)

          assert_equal 'shop', query_field.name
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
