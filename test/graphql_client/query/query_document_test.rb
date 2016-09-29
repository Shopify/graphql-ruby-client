require 'test_helper'

module GraphQL
  module Client
    module Query
      class QueryDocumentTest < Minitest::Test
        def setup
          schema_string = File.read(fixture_path('merchant_schema.json'))
          @schema = GraphQLSchema.new(schema_string)
        end

        def test_new_creates_a_document_with_a_query_operation
          query_operation = QueryDocument.new(@schema)

          assert_equal query_operation, query_operation.document.operations['default']
          assert_instance_of QueryOperation, query_operation
        end

        def test_new_yields_query_operation
          query_operation_object = nil

          query_operation = QueryDocument.new(@schema) do |q|
            query_operation_object = q
          end

          assert_equal query_operation_object, query_operation
        end
      end
    end
  end
end
