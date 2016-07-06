# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class MutationOperation < Operation
        def operation_type
          'mutation'
        end

        def resolver_type
          schema.type(schema.mutation_root_name)
        end
      end
    end
  end
end
