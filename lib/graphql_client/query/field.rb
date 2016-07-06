# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class Field
        include AddInlineFragment
        include HasSelectionSet

        INVALID_ARGUMENTS = Class.new(StandardError)

        attr_reader :arguments, :as, :document, :field_defn

        def initialize(field_defn, document:, arguments: {}, as: nil)
          @field_defn = field_defn
          @document = document
          @arguments = validate_arguments(arguments)
          @as = as
          @selection_set = SelectionSet.new
        end

        def add_arguments(**arguments)
          new_arguments = validate_arguments(arguments)
          @arguments.merge!(new_arguments)
        end

        def aliased?
          name != field_defn.name
        end

        def arguments=(arguments)
          @arguments = validate_arguments(arguments)
        end

        def connection?
          resolver_type.name.to_s.end_with?('Connection')
        end

        def name
          as || field_defn.name
        end

        def node?
          field_defn.name == 'Node' || (resolver_type.object? && resolver_type.implement?('Node'))
        end

        def resolver_type
          @resolver_type ||= schema.type(field_defn.type.unwrap.name)
        end

        def schema
          document.schema
        end

        def to_query(indent: '')
          indent.dup.tap do |query_string|
            query_string << "#{as}: " if aliased?
            query_string << field_defn.name
            query_string << "(#{arguments_string.join(', ')})" if arguments.any?

            unless selection_set.empty?
              query_string << " {\n"
              query_string << selection_set.to_query(indent)
              query_string << "\n#{indent}}"
            end
          end
        end

        alias_method :to_s, :to_query

        private

        def arguments_string
          arguments.map do |name, value|
            "#{name}: #{value.to_query}"
          end
        end

        def validate_arguments(arguments)
          arguments.each_with_object({}) do |(arg_name, value), hash|
            if field_defn.args.any? { |arg| arg.name == arg_name.to_s }
              hash[arg_name] = value.is_a?(Argument) ? value : Argument.new(value)
            else
              raise INVALID_ARGUMENTS, "#{arg_name} is not a valid arg for #{name}"
            end
          end
        end
      end
    end
  end
end
