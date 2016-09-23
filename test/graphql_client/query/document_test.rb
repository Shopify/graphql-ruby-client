require 'test_helper'

module GraphQL
  module Client
    module Query
      class DocumentTest < Minitest::Test
        def setup
          schema_string = File.read(fixture_path('merchant_schema.json'))
          @schema = GraphQLSchema.new(schema_string)
        end

        def test_initialize_yields_self
          document_object = nil

          document = Document.new(@schema) do |d|
            document_object = d
          end

          assert_equal document_object, document
        end

        def test_add_mutation_creates_a_mutation_operation
          document = Document.new(@schema)
          mutation = document.add_mutation('createUser')

          assert_instance_of MutationOperation, mutation
          assert_equal({ 'createUser' => mutation }, document.operations)
        end

        def test_add_query_creates_a_query_operation
          document = Document.new(@schema)
          query = document.add_query('getUser')

          assert_instance_of QueryOperation, query
          assert_equal({ 'getUser' => query }, document.operations)
          assert_equal 1, document.operations.size
        end

        def test_add_operation_sets_default_name
          document = Document.new(@schema)
          query = document.add_query

          assert_instance_of QueryOperation, query
          assert_equal({ 'default' => query }, document.operations)
          assert_equal 1, document.operations.size
        end

        def test_add_operation_yields_block
          document = Document.new(@schema)
          query_object = nil

          query = document.add_query do |q|
            query_object = q
          end

          assert_equal query_object, query
        end

        def test_add_operation_supports_multiple_unique_operations
          document = Document.new(@schema)
          document.add_query('getUser')
          document.add_query('getPosts')

          assert_equal 2, document.operations.size
          assert_equal %w(getUser getPosts), document.operations.keys
        end

        def test_add_operation_enforces_unique_names
          document = Document.new(@schema)
          document.add_query('getUser')

          assert_raises Document::DUPLICATE_OPERATION_NAME do
            document.add_query('getUser')
          end
        end

        def test_add_operation_requires_a_document_with_multiple_operations_to_all_be_named
          document = Document.new(@schema)
          document.add_query

          assert_raises Document::INVALID_DOCUMENT do
            document.add_query('getUser')
          end
        end

        def test_to_query_joins_all_operations
          document = Document.new(@schema) do |d|
            d.add_query('shopQuery') do |q|
              q.add_field('shop') do |shop|
                shop.add_field('name')
              end
            end

            d.add_mutation('tokens') do |m|
              m.add_field('publicAccessTokenCreate', input: { title: 'Token Title' }) do |create|
                create.add_field('publicAccessToken') do |public_access_token|
                  public_access_token.add_field('title')
                end
              end
            end
          end

          query_string = <<~QUERY
            query shopQuery {
              shop {
                name
              }
            }

            mutation tokens {
              publicAccessTokenCreate(input: { title: "Token Title" }) {
                publicAccessToken {
                  title
                }
              }
            }
          QUERY

          assert_equal query_string, document.to_query
        end
      end
    end
  end
end
