require 'json'

module GraphQL
  module Client
    class Response
      ResponseError = Class.new(StandardError)
      attr_reader :data

      def initialize(request, response)
        @page = 1
        @response = response
        @request = request

        parsed_response = JSON.parse(@response)
        if parsed_response.key?('errors')
          raise ResponseError, "Malformed response - #{response}"
        end

        @data = parsed_response['data']
      end

      def object
        type_name = @data.keys.first
        @data[type_name]
      end
    end
  end
end
