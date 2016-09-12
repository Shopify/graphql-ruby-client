module GraphQL
  module Client
    module Query
      class Operation
        include SelectionSet

        attr_reader :selection_set, :schema

        def initialize(schema)
          @schema = schema
          @selection_set = []

          yield self if block_given?
        end
      end
    end
  end
end
