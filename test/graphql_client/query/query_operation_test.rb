require 'test_helper'

module GraphQL
  module Client
    module Query
      class QueryOperationTest < Minitest::Test
        def setup
          @schema = GraphQLSchema.new(schema_fixture('schema.json'))
          @graphql_schema = GraphQL::Schema::Loader.load(schema_fixture('schema.json'))
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

          mock_schema.expect(:query_root_name, 'queryRoot')
          mock_schema.expect(:type, nil, ['queryRoot'])

          query.resolver_type

          assert mock_schema.verify
        end

        def test_to_query_with_a_single_query_field
          document = Document.new(@schema)

          query = QueryOperation.new(document) do |q|
            q.add_field('shop') do |s|
              s.add_field('productByHandle', handle: "test") do |product|
                product.add_field('title')
              end
            end
          end

          query_string = <<~QUERY
            query {
              shop {
                productByHandle(handle: "test") {
                  id
                  title
                }
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema
        end

        def test_to_query_with_a_field_alias
          document = Document.new(@schema)

          query = QueryOperation.new(document) do |q|
            q.add_field('shop') do |s|
              s.add_field('productByHandle', handle: 'test', as: 'userProduct') do |product|
                product.add_field('title')
              end
            end
          end

          query_string = <<~QUERY
            query {
              shop {
                userProduct: productByHandle(handle: \"test\") {
                  id
                  title
                }
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema
        end

        def test_to_query_handles_multiple_nested_query_fields
          document = Document.new(@schema)

          query = QueryOperation.new(document) do |q|

            q.add_field('shop') do |shop|
              shop.add_field('name')

              shop.add_field('privacyPolicy') do |policy|
                policy.add_field('body')
              end

              shop.add_field('productByHandle', handle: 'test') do |product|
                product.add_field('title')
              end
            end
          end

          query_string = <<~QUERY
            query {
              shop {
                name
                privacyPolicy {
                  id
                  body
                }
                productByHandle(handle: "test") {
                  id
                  title
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
            q.add_field('shop') do |shop|
              shop.add_field('name')

              shop.add_field('productByHandle', handle: 'test') do |product|
                product.add_field('title')
              end
            end
          end

          query_string = <<~QUERY
            query {
              shop {
                name
                productByHandle(handle: "test") {
                  id
                  title
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
            q.add_field('shop') do |s|
              s.add_field('productByHandle', handle: 'test') do |product|
                product.add_connection('images', first: 10) do |connection|
                  connection.add_field('src')
                end
              end
            end
          end

          query_string = <<~QUERY
            query {
              shop {
                productByHandle(handle: \"test\") {
                  id
                  images(first: 10) {
                    edges {
                      cursor
                      node {
                        src
                      }
                    }
                    pageInfo {
                      hasPreviousPage
                      hasNextPage
                    }
                  }
                }
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema
        end

        def test_to_query_adds_node_id_if_type_implements_node
          document = Document.new(@schema)

          query = QueryOperation.new(document) do |q|
            q.add_field('shop') do |s|
              s.add_field('productByHandle', handle: 'test') do |product|
                product.add_connection('variants', first: 10) do |connection|
                  connection.add_field('title')
                end
              end
            end
          end

          query_string = <<~QUERY
            query {
              shop {
                productByHandle(handle: \"test\") {
                  id
                  variants(first: 10) {
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
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema
        end

        def test_to_query_handles_variables
          document = Document.new(@schema)

          query = QueryOperation.new(document, variables: { productHandle: 'String!' }) do |q|
            q.add_field('shop') do |shop|
              shop.add_field('productByHandle', handle: '$productHandle') do |product|
                product.add_field('title')
              end
            end
          end

          query_string = <<~QUERY
            query($productHandle: String!) {
              shop {
                productByHandle(handle: $productHandle) {
                  id
                  title
                }
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema, variables: { 'productHandle' => 'test' }
        end
      end
    end
  end
end
