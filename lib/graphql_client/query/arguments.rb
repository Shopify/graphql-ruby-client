module GraphQL
  module Client
    module Query
      class Arguments
        def initialize(arguments)
          @arguments = arguments
        end

        def to_query
          arguments = @arguments.map do |(name, value)|
            if value.is_a? Hash
              hash_query_string = value.map { |(k, v)| sub_query(k, v) }
              "#{name}: { #{hash_query_string.join(', ')} }"
            else
              sub_query(name, value)
            end
          end

          "(#{arguments.join(', ')})" if arguments.any?
        end

        private

        def query_value(value)
          value.is_a?(Integer) ? value : "\"#{value}\""
        end

        def sub_query(name, value)
          "#{name}: #{query_value(value)}"
        end
      end
    end
  end
end
