# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class Operation
        include HasSelectionSet

        attr_reader :document, :name, :selection_set, :variables

        def initialize(document, name: nil, variables: {})
          @document = document
          @name = name
          @selection_set = SelectionSet.new
          @variables = variables

          yield self if block_given?
        end

        def schema
          document.schema
        end

        def to_query
          operation_type.dup.tap do |query_string|
            query_string << " #{name}" if name
            query_string << "(#{variables_string.join(', ')})" if variables.any?
            query_string << " {\n"
            query_string << selection_set.to_query
            query_string << "\n}\n"
          end
        end

        alias_method :to_s, :to_query

        private

        def variables_string
          variables.map do |name, type|
            "$#{name}: #{type}"
          end
        end
      end
    end
  end
end
