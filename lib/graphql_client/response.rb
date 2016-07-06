require 'json'

module GraphQL
  module Client
    class Response
      attr_reader :data

      def initialize(request, response)
        @page = 1
        @response = response
        @request = request
        @data = JSON.parse(@response)['data']
      end

      def object
        type_name = @data.keys.first
        @data[type_name]
      end
    end
  end
end
