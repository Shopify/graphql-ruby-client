# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class Operation
        include SelectionSet

        attr_reader :name, :selection_set, :schema

        def initialize(schema, name: nil)
          @schema = schema
          @name = name
          @selection_set = []

          yield self if block_given?
        end

        def to_query
          query_string = ''.dup
          query_string << operation_type
          query_string << " #{name}" if name
          query_string << " {\n"
          query_string << selection_set_query
          query_string << "\n}\n"
          query_string
        end
      end
    end
  end
end
