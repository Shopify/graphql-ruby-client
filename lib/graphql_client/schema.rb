module GraphQL
  module Client
    class Schema
      def initialize(schema_text)
        @types = build_type_map(schema_text)
        @normalized_types = {}
        @types.each do |name, type|
          @normalized_types[name.downcase] = type
        end
      end

      def query_root
        @types['QueryRoot']
      end

      def type(name)
        @normalized_types[name.downcase]
      end

      private

      def build_type_map(schema_text)
        {}.tap do |types|
          parsed_schema = JSON.parse(schema_text)

          parsed_schema['data']['__schema']['types'].each do |type|
            types[type['name']] = Type.new(type['name'], type)
          end
        end
      end
    end
  end
end
