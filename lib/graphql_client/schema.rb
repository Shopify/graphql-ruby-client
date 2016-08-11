module GraphQL
  module Client
    class Schema
      def initialize(schema_text)
        @schema_text = schema_text
      end

      def [](type_name)
        type(type_name)
      end

      def query_root
        type('QueryRoot')
      end

      def type(type_name)
        types[type_name.downcase]
      end

      def types
        @types ||= schema.dig('data', '__schema', 'types').each_with_object({}) do |type, types|
          name = type['name'].downcase
          types[name] = Type.new(type['name'], type)
        end
      end

      private

      attr_reader :schema_text

      def schema
        @schema ||= JSON.parse(schema_text)
      end
    end
  end
end
