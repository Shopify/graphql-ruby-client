# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class InlineFragment
        include SelectionSet

        attr_reader :document, :type, :selection_set

        def initialize(type, document:)
          @type = type
          @document = document
          @selection_set = []

          yield self if block_given?
        end

        def resolver_type
          type
        end

        def to_query(indent: '')
          indent.dup.tap do |query_string|
            query_string << "... on #{type.name} {\n"
            query_string << selection_set_query(indent)
            query_string << "\n#{indent}}"
          end
        end
      end
    end
  end
end
