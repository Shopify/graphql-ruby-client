# frozen_string_literal: true

module GraphQL
  module Client
    class ResponseObject
      include Deserialization

      attr_reader :data

      def initialize(data)
        @data = Hash(data)

        @data.each do |field_name, value|
          response_object = case value
          when Hash
            if value.key?('edges')
              ResponseConnection.new(value)
            else
              self.class.new(value)
            end
          when Array
            value.map { |v| v.is_a?(Hash) ? self.class.new(v) : v }
          else
            value
          end

          create_accessor_methods(field_name, response_object)
        end
      end
    end
  end
end
