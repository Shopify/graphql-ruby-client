# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class QueryDocument
        def self.new(schema, name = nil)
          document = Document.new(schema)
          query = document.add_query(name)

          if block_given?
            yield query
          end

          query
        end
      end
    end
  end
end
