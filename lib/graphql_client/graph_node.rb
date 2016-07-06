# frozen_string_literal: true

module GraphQL
  module Client
    class GraphNode < GraphObject
      def build_minimal_query
        Query::QueryDocument.new(query.schema) do |root|
          root.add_field('node', id: data.fetch('id')) do |node|
            node.add_inline_fragment(query.resolver_type.name) do |fragment|
              fragment.add_field('id')
              yield fragment
            end
          end
        end
      end

      def refetch_query
        build_minimal_query do |node_fragment|
          node_fragment.selection_set = query.selection_set
        end
      end
    end
  end
end
