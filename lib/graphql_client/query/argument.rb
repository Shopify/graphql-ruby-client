require 'json'

module GraphQL
  module Client
    module Query
      class Argument
        attr_reader :value

        def initialize(value)
          @value = value
        end

        def to_query
          case value
          when FalseClass, Float, Integer, NilClass, String, TrueClass
            generate_query_value(value)
          when Array
            "[#{value.map { |v| generate_query_value(v) }.join(', ')}]"
          when Hash
            "{ #{value.map { |k, v| "#{k}: #{generate_query_value(v)}" }.join(', ')} }"
          end
        end

        private

        def generate_query_value(value)
          JSON.generate(value, quirks_mode: true)
        end
      end
    end
  end
end
