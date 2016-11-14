# frozen_string_literal: true

module GraphQL
  module Client
    module Query
      class QueryField
        include AddInlineFragment
        include HasSelectionSet

        INVALID_ARGUMENTS = Class.new(StandardError)

        attr_reader :arguments, :as, :document, :field

        def initialize(field, document:, arguments: {}, as: nil)
          @field = field
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
          name != field.name
        end

        def arguments=(arguments)
          @arguments = validate_arguments(arguments)
        end

        def name
          as || field.name
        end

        def resolver_type
          field.base_type
        end

        def to_query(indent: '')
          indent.dup.tap do |query_string|
            query_string << "#{as}: " if aliased?
            query_string << field.name
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
          valid_args = field.args.keys

          arguments.each_with_object({}) do |(name, value), hash|
            if valid_args.include?(name.to_s)
              hash[name] = value.is_a?(Argument) ? value : Argument.new(value)
            else
              raise INVALID_ARGUMENTS, "#{name} is not a valid arg for #{field.name}"
            end
          end
        end
      end
    end
  end
end
