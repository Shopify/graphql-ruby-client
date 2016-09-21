# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class Operation
        include SelectionSet

        attr_reader :document, :name, :selection_set

        def initialize(document, name: nil)
          @document = document
          @name = name
          @selection_set = []

          yield self if block_given?
        end

        def schema
          document.schema
        end

        def to_query
          operation_type.dup.tap do |query_string|
            query_string << " #{name}" if name
            query_string << " {\n"
            query_string << selection_set_query
            query_string << "\n}\n"
          end
        end
      end
    end
  end
end
