module GraphQL
  module Client
    class Schema
      attr_reader :types

      def initialize(schema_text)
        @types = build_type_map(schema_text)
      end

      private

      def build_type_map(schema_text)
        {}.tap do |types|
          parsed_schema = JSON.parse(schema_text).with_indifferent_access

          parsed_schema[:data][:__schema][:types].each do |type|
            types[type[:name]] = Type.new(type[:name], type)
          end
        end
      end
    end
  end
end
