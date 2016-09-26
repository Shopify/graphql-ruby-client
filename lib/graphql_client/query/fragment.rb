# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class Fragment
        include AddInlineFragment
        include SelectionSet

        attr_reader :document, :name, :type, :selection_set

        def initialize(name, type, document:)
          @name = name
          @type = type
          @document = document
          @selection_set = []

          yield self if block_given?
        end

        def resolver_type
          type
        end

        def to_definition(indent: '')
          indent.dup.tap do |query_string|
            query_string << "fragment #{name} on #{type.name} {\n"
            query_string << selection_set_query(indent)
            query_string << "\n#{indent}}\n"
          end
        end

        def to_query(indent: '')
          "#{indent}...#{name}"
        end
      end
    end
  end
end
