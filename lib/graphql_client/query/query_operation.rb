module GraphQL
  module Client
    module Query
      class QueryOperation < Operation
        def resolver_type
          schema.query_root
        end

        def to_query
          <<~QUERY
            query {
            #{selection_set_query}
            }
          QUERY
        end
      end
    end
  end
end
