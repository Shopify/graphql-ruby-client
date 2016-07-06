# frozen_string_literal: true

module GraphQL
  module Client
    module Deserialization
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
