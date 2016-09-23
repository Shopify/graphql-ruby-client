# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class Document
        DEFAULT_OPERATION_NAME = 'default'

        DUPLICATE_OPERATION_NAME = Class.new(StandardError)
        INVALID_DOCUMENT = Class.new(StandardError)

        attr_reader :operations, :schema

        def initialize(schema)
          @schema = schema
          @operations = {}

          yield self if block_given?
        end

        def add_mutation(name = nil, &block)
          add_operation(MutationOperation, name, &block)
        end

        def add_query(name = nil, &block)
          add_operation(QueryOperation, name, &block)
        end

        def to_query
          operations.values.map(&:to_query).join("\n")
        end

        private

        def add_operation(operation_type, name)
          if operations.key?(DEFAULT_OPERATION_NAME)
            raise INVALID_DOCUMENT, 'a document with multiple operations must have named operations'
          end

          operation = operation_type.new(schema, name: name)
          operation_name = operation.name || DEFAULT_OPERATION_NAME

          if operations.key?(operation_name)
            raise DUPLICATE_OPERATION_NAME, "an operation named #{operation_name} already exists in the document"
          end

          @operations[operation_name] = operation

          if block_given?
            yield operation
          else
            operation
          end
        end
      end
    end
  end
end
