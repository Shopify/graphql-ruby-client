module GraphQL
  module Client
    module Query
      class QueryField
        include Field

        INVALID_ARGUMENTS = Class.new(StandardError)

        attr_reader :arguments, :field, :query_fields

        def initialize(field, arguments: {})
          @field = field
          @arguments = validate_arguments(arguments)
          @query_fields = []
        end

        def resolver_type
          field.base_type
        end

        def to_query(indent: '')
          query_string = "#{indent}#{@field.name}#{@arguments.to_query}"

          if selection_set?
            query_string << " {\n"
            query_string << query_fields_string(indent)
            query_string << "\n#{indent}}"
          end

          query_string
        end

        private

        def query_fields_string(indent)
          query_fields.map { |qf| qf.to_query(indent: indent + '  ') }.join("\n")
        end

        def selection_set?
          !query_fields.empty?
        end

        def validate_arguments(arguments)
          arguments = arguments.reject { |_, value| value.nil? }
          invalid_arguments = arguments.keys.map(&:to_s) - field.args.keys

          if invalid_arguments.empty?
            Arguments.new(arguments)
          else
            raise INVALID_ARGUMENTS, invalid_arguments.to_a.join(',')
          end
        end
      end
    end
  end
end
