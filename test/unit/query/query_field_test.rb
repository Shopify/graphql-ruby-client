require 'test_helper'

module GraphQL
  module Client
    module Query
      class QueryFieldTest < Minitest::Test
        def setup
          schema_string = File.read(fixture_path('merchant_schema.json'))
          @schema = GraphQLSchema.new(schema_string)
        end

        def test_validates_arguments
          field = @schema.query_root.fields.fetch('shop')

          assert_raises QueryField::INVALID_ARGUMENTS do
            QueryField.new(field, arguments: { id: 2 })
          end
        end

        def test_add_field_creates_field_and_adds_to_query_fields
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, arguments: {})

          query_field.add_field('name')

          assert_equal 1, query_field.query_fields.size
        end

        def test_resolver_type_is_the_fields_base_type
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, arguments: {})

          assert_equal field.base_type, query_field.resolver_type
        end

        def test_to_query_is_the_graphql_query_string
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, arguments: {})

          assert_equal 'shop', query_field.to_query
        end

        def test_to_query_includes_the_query_fields_selection_set
          field = @schema.query_root.fields.fetch('shop')
          query_field = QueryField.new(field, arguments: {})

          query_field.add_field('name')

          query_string = <<~QUERY
            shop {
              name
            }
          QUERY

          assert_equal query_string.chomp, query_field.to_query
        end

        def test_to_query_includes_arguments
          field = @schema.query_root.fields.fetch('product')
          query_field = QueryField.new(field, arguments: { id: '2' })

          query_field.add_field('title')

          query_string = <<~QUERY
            product(id: "2") {
              title
            }
          QUERY

          assert_equal query_string.chomp, query_field.to_query
        end
      end
    end
  end
end
