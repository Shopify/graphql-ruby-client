module GraphQL
  module Client
    module Query
      class Operation
        include Field

        attr_reader :query_fields, :schema

        def initialize(schema)
          @schema = schema
          @query_fields = []

          yield self if block_given?
        end

        private

        def query_fields_string
          @query_fields.map do |query_field|
            query_field.to_query(indent: '  ')
          end.join("\n")
        end
      end
    end
  end
end
