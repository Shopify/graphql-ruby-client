require 'test_helper'

module GraphQL
  module Client
    module Query
      class MutationOperationTest < Minitest::Test
        def setup
          schema_string = File.read(fixture_path('merchant_schema.json'))
          @schema = GraphQLSchema.new(schema_string)
          @graphql_schema = GraphQL::Schema::Loader.load(JSON.parse(schema_string))
        end

        def test_initialize_yields_self
          document = Document.new(@schema)
          query_object = nil

          query = MutationOperation.new(document) do |q|
            query_object = q
          end

          assert_equal query_object, query
        end

        def test_resolver_type_is_the_schemas_mutation_root
          mock_schema = Minitest::Mock.new
          document = Document.new(mock_schema)

          query = MutationOperation.new(document)

          mock_schema.expect(:mutation_root, nil)
          query.resolver_type

          assert mock_schema.verify
        end

        def test_to_query_handles_multiple_nested_selection_set
          document = Document.new(@schema)

          query = MutationOperation.new(document) do |q|
            q.add_field('publicAccessTokenCreate', input: { title: 'Token Title' }) do |mutation|
              mutation.add_field('publicAccessToken') do |public_access_token|
                public_access_token.add_field('title')
                public_access_token.add_field('accessToken')
              end
            end
          end

          query_string = <<~QUERY
            mutation {
              publicAccessTokenCreate(input: { title: "Token Title" }) {
                publicAccessToken {
                  title
                  accessToken
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
