# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class QueryOperation < Operation
        def operation_type
          'query'
        end

        def resolver_type
          schema.type(schema.query_root_name)
        end
      end
    end
  end
end
