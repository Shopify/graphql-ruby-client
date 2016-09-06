module GraphQL
  module Client
    module Query
      class MutationOperation < Operation
        def resolver_type
          schema.mutation_root
        end

        def to_query
          <<~QUERY
            mutation {
            #{query_fields_string}
            }
          QUERY
        end
      end
    end
  end
end
