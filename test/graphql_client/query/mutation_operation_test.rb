require 'test_helper'

module GraphQL
  module Client
    module Query
      class MutationOperationTest < Minitest::Test
        def setup
          @schema = GraphQLSchema.new(schema_fixture('schema.json'))
          @graphql_schema = GraphQL::Schema::Loader.load(schema_fixture('schema.json'))
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

          mock_schema.expect(:mutation_root_name, 'mutationRoot')
          mock_schema.expect(:type, nil, ['mutationRoot'])

          query.resolver_type

          assert mock_schema.verify
        end

        def test_to_query_handles_multiple_nested_selection_set
          document = Document.new(@schema)

          query = MutationOperation.new(document) do |q|
            q.add_field('customerCreate', input: { email: 'email', password: 'password' }) do |mutation|
              mutation.add_field('customer') do |customer|
                customer.add_field('email')
              end
            end
          end

          query_string = <<~QUERY
            mutation {
              customerCreate(input: { email: "email", password: "password" }) {
                customer {
                  email
                }
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema
        end

        def test_to_query_handles_variables
          document = Document.new(@schema)

          query = MutationOperation.new(document, variables: { email: 'String!' }) do |q|
            q.add_field('customerCreate', input: { email: '$email', password: 'password' }) do |mutation|
              mutation.add_field('customer') do |customer|
                customer.add_field('email')
              end
            end
          end

          query_string = <<~QUERY
            mutation($email: String!) {
              customerCreate(input: { email: $email, password: \"password\" }) {
                customer {
                  email
                }
              }
            }
          QUERY

          assert_equal query_string, query.to_query
          assert_valid_query query_string, @graphql_schema, variables: { 'email' => 'email' }
        end
      end
    end
  end
end
