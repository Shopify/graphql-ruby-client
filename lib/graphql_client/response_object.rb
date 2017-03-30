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
              wrap(value)
            end
          when Array
            value.map { |v| wrap(v) }
          else
            value
          end

          create_accessor_methods(field_name, response_object)
        end
      end

      def wrap(data)
        data = self.class.new(data) if data.is_a?(Hash)
        data
      end
    end
  end
end
