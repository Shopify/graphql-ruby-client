# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class MutationDocument
        def self.new(schema, name = nil)
          document = Document.new(schema)
          mutation = document.add_mutation(name)

          if block_given?
            yield mutation
          end

          mutation
        end
      end
    end
  end
end
