# frozen_string_literal: true

module GraphQL
  module Client
    class GraphConnection < GraphObject
      include Enumerable

      def each
        return enum_for(:each) unless block_given?
        edges.each { |edge| yield edge.node }
      end

      def next_page_query
        build_minimal_query do |connection|
          connection.add_arguments(**query.arguments, after: edges.last.cursor)
          connection.selection_set = query.selection_set
        end
      end
    end
  end
end
