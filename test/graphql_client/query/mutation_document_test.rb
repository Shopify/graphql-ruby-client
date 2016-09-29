require 'test_helper'

module GraphQL
  module Client
    module Query
      class QueryDocumentTest < Minitest::Test
        def setup
          schema_string = File.read(fixture_path('merchant_schema.json'))
          @schema = GraphQLSchema.new(schema_string)
        end

        def test_new_creates_a_document_with_a_mutation_operation
          mutation_operation = MutationDocument.new(@schema)

          assert_equal mutation_operation, mutation_operation.document.operations['default']
          assert_instance_of MutationOperation, mutation_operation
        end

        def test_new_yields_mutation_operation
          mutation_operation_object = nil

          mutation_operation = MutationDocument.new(@schema) do |q|
            mutation_operation_object = q
          end

          assert_equal mutation_operation_object, mutation_operation
        end
      end
    end
  end
end
