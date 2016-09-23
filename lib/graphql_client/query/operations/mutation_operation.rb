# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class MutationOperation < Operation
        def operation_type
          'mutation'
        end

        def resolver_type
          schema.mutation_root
        end
      end
    end
  end
end
