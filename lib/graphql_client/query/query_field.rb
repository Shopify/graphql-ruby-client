module GraphQL
  module Client
    module Query
      class QueryField
        include SelectionSet

        INVALID_ARGUMENTS = Class.new(StandardError)

        attr_reader :arguments, :field, :selection_set

        def initialize(field, arguments: {})
          @field = field
          @arguments = validate_arguments(arguments)
          @selection_set = []
        end

        def resolver_type
          field.base_type
        end

        def to_query(indent: '')
          query_string = "#{indent}#{field.name}"
          query_string << "(#{arguments_string.join(', ')})" if arguments.any?

          if selection_set?
            query_string << " {\n"
            query_string << selection_set_query(indent)
            query_string << "\n#{indent}}"
          end

          query_string
        end

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
              hash[name] = Argument.new(value)
            else
              raise INVALID_ARGUMENTS, "#{name} is not a valid arg for #{field.name}"
            end
          end
        end
      end
    end
  end
end
