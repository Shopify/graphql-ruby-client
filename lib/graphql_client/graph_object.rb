# frozen_string_literal: true

module GraphQL
  module Client
    class GraphObject
      attr_reader :data, :parent, :query

      def initialize(query:, data:, parent: nil)
        @query = query
        @data = data
        @parent = parent

        @data.each do |field_name, value|
          query_field = query.selection_set.lookup(field_name)

          graph_object = case value
          when Hash
            klass = if query_field.field.connection?
              GraphConnection
            elsif query_field.node?
              GraphNode
            else
              GraphObject
            end

            klass.new(query: query_field, data: value, parent: self)
          when Array
            value.map { |v| self.class.new(query: query_field, data: v, parent: self) }
          else
            value
          end

          create_accessor_methods(field_name, graph_object)
        end
      end

      def build_minimal_query
        if parent
          parent.build_minimal_query do |context|
            yield context.add_field(query.field.name, as: query.name, **query.arguments)
          end
        else
          Query::QueryDocument.new(query.schema) { |root| yield root }
        end
      end

      private

      def create_accessor_methods(field_name, graph_object)
        define_singleton_method(field_name) do
          ivar_name = "@#{field_name}"

          if instance_variable_defined?(ivar_name)
            instance_variable_get(ivar_name)
          else
            instance_variable_set(ivar_name, graph_object)
          end
        end

        underscored_name = underscore(field_name)

        if field_name != underscored_name
          define_singleton_method(underscored_name) { send field_name }
        end
      end

      def underscore(name)
        name
          .gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end
    end
  end
end
