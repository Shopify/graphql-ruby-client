# frozen_string_literal: true

module GraphQL
  module Client
    class GraphObject
      include Deserialization

      attr_reader :data, :parent, :query

      def initialize(query:, data:, parent: nil)
        @query = query
        @data = Hash(data)
        @parent = parent

        @data.each do |field_name, value|
          field = query.selection_set.lookup(field_name)

          graph_object = case value
          when Hash
            klass = if field.connection?
              GraphConnection
            elsif field.node?
              GraphNode
            else
              GraphObject
            end

            klass.new(query: field, data: value, parent: self)
          when Array
            value.map { |v| self.class.new(query: field, data: v, parent: self) }
          else
            value
          end

          create_accessor_methods(field_name, graph_object)
        end
      end

      def build_minimal_query
        if parent
          parent.build_minimal_query do |context|
            yield context.add_field(query.field_defn.name, as: query.name, **query.arguments)
          end
        else
          Query::QueryDocument.new(query.schema) { |root| yield root }
        end
      end
    end
  end
end
