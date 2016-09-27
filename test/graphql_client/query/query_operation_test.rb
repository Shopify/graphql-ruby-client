require 'test_helper'

module GraphQL
  module Client
    module Query
      class QueryOperationTest < Minitest::Test
        def setup
          schema_string = File.read(fixture_path('merchant_schema.json'))
          @schema = GraphQLSchema.new(schema_string)

          @graphql_schema = GraphQL::Schema::Loader.load(JSON.parse(schema_string))
        end

        def test_initialize_yields_self
          query_object = nil
          document = Document.new(@schema)

          query = QueryOperation.new(document) do |q|
            query_object = q
          end

          assert_equal query_object, query
        end

        def test_resolver_type_is_the_schemas_query_root
          mock_schema = Minitest::Mock.new
          document = Document.new(mock_schema)
          query = QueryOperation.new(document)

          mock_schema.expect(:query_root, nil)
          query.resolver_type

          assert mock_schema.verify
        end

        def test_to_query_with_a_single_query_field
          document = Document.new(@schema)

          query = QueryOperation.new(document) do |q|
            q.add_field('product', id: '2') do |product|
              product.add_field('title')
            end
          end

          query_string = <<~QUERY
            query {
              product(id: "2") {
                title
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema
        end

        def test_to_query_with_a_field_alias
          document = Document.new(@schema)

          query = QueryOperation.new(document) do |q|
            q.add_field('product', id: '2', as: 'userProduct') do |product|
              product.add_field('title')
            end
          end

          query_string = <<~QUERY
            query {
              userProduct: product(id: "2") {
                title
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema
        end

        def test_to_query_handles_multiple_nested_query_fields
          document = Document.new(@schema)

          query = QueryOperation.new(document) do |q|
            q.add_field('product', id: 'gid://Product/1') do |product|
              product.add_field('title')
            end

            q.add_field('shop') do |shop|
              shop.add_field('name')

              shop.add_field('billingAddress') do |billing_address|
                billing_address.add_field('city')
                billing_address.add_field('country')
              end
            end
          end

          query_string = <<~QUERY
            query {
              product(id: "gid://Product/1") {
                title
              }
              shop {
                name
                billingAddress {
                  city
                  country
                }
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema
        end

        def test_to_query_handles_add_fields
          document = Document.new(@schema)

          query = QueryOperation.new(document) do |q|
            q.add_field('product', id: 'gid://Product/1') do |product|
              product.add_field('title')
            end

            q.add_field('shop') do |shop|
              shop.add_field('name')

              shop.add_field('billingAddress') do |billing_address|
                billing_address.add_fields('city', 'country')
              end
            end
          end

          query_string = <<~QUERY
            query {
              product(id: "gid://Product/1") {
                title
              }
              shop {
                name
                billingAddress {
                  city
                  country
                }
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema
        end

        def test_to_query_handles_connections
          document = Document.new(@schema)

          query = QueryOperation.new(document) do |q|
            q.add_field('product', id: 'gid://Product/1') do |product|
              product.add_connection('images', first: 10) do |connection|
                connection.add_field('src')
              end
            end
          end

          query_string = <<~QUERY
            query {
              product(id: "gid://Product/1") {
                images(first: 10) {
                  edges {
                    cursor
                    node {
                      src
                    }
                  }
                  pageInfo {
                    hasNextPage
                  }
                }
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema
        end
      end
    end
  end
end
