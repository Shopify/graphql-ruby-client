require 'test_helper'

module GraphQL
  module Client
    module Query
      class FieldTest < Minitest::Test
        def setup
          @schema = GraphQLSchema.new(schema_fixture('merchant_schema.json'))
          @document = Document.new(@schema)
        end

        def test_validates_arguments
          field_defn = @schema.query_root.field('shop')

          assert_raises Field::INVALID_ARGUMENTS do
            Field.new(field_defn, document: @document, arguments: { id: 2 })
          end
        end

        def test_add_arguments_merges_new_arguments_with_existing_ones
          shop = @schema.query_root.field('shop')
          products_defn = schema_type(shop.type).field('products')
          field = Field.new(products_defn, document: @document, arguments: { first: 5 })

          field.add_arguments(first: 10, after: 'cursor')

          first_arg = Argument.new(10)
          after_arg = Argument.new('cursor')

          assert_equal({ first: first_arg, after: after_arg }, field.arguments)
        end

        def test_add_field_creates_field_and_adds_to_selection_set
          field_defn = @schema.query_root.field('shop')
          field = Field.new(field_defn, document: @document, arguments: {})

          name = field.add_field('name')

          assert_equal({ 'name' => name }, field.selection_set.fields)
        end

        def test_add_field_does_not_add_duplicate_fields
          field_defn = @schema.query_root.field('shop')
          field = Field.new(field_defn, document: @document, arguments: {})

          field.add_field('name')
          new_name = field.add_field('name')

          assert_equal({ 'name' => new_name }, field.selection_set.fields)
        end

        def test_add_field_allows_multiple_fields_of_same_type_with_aliases
          field_defn = @schema.query_root.field('shop')
          field = Field.new(field_defn, document: @document, arguments: {})

          name = field.add_field('name')
          myname = field.add_field('name', as: 'myname')

          assert_equal({ 'name' => name, 'myname' => myname }, field.selection_set.fields)
        end

        def test_add_fields_creates_multiple_fields
          field_defn = @schema.query_root.field('shop')
          field = Field.new(field_defn, document: @document, arguments: {})

          field.add_fields('id', 'name')

          assert_equal %w(id name), field.selection_set.fields.keys
        end

        def test_add_field_uses_as_alias_name
          field_defn = @schema.query_root.field('shop')
          field = Field.new(field_defn, document: @document, arguments: {}, as: 'myshop')

          field.add_field('name')

          query_string = <<~QUERY
            myshop: shop {
              name
            }
          QUERY

          assert_equal query_string.chomp, field.to_query
        end

        def test_name_returns_alias_if_set
          field_defn = @schema.query_root.field('shop')
          field = Field.new(field_defn, document: @document, as: 'myshop')

          assert_equal 'myshop', field.name
        end

        def test_name_defaults_to_field_name
          field_defn = @schema.query_root.field('shop')
          field = Field.new(field_defn, document: @document)

          assert_equal 'shop', field.name
        end

        def test_resolver_type_is_the_fields_base_type
          field_defn = @schema.query_root.field('shop')
          field = Field.new(field_defn, document: @document, arguments: {})

          assert_equal schema_type(field_defn.type), field.resolver_type
        end

        def test_to_query_is_the_graphql_query_string
          field_defn = @schema.query_root.field('shop')
          field = Field.new(field_defn, document: @document, arguments: {})

          assert_equal 'shop', field.to_query
        end

        def test_to_query_includes_the_selection_set_selection_set
          field_defn = @schema.query_root.field('shop')
          field = Field.new(field_defn, document: @document, arguments: {})

          field.add_field('name')

          query_string = <<~QUERY
            shop {
              name
            }
          QUERY

          assert_equal query_string.chomp, field.to_query
        end

        def test_to_query_includes_arguments
          field_defn = @schema.query_root.field('shop')

          shop = Field.new(field_defn, document: @document)
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
