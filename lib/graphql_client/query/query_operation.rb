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
            #{query_fields_string}
            }
          QUERY
        end
      end
    end
  end
end
