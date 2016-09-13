module GraphQL
  module Client
    class Response
      MalformedError = Class.new(StandardError)

      attr_reader :data

      def initialize(response_body)
        parsed_response = JSON.parse(response_body)

        if parsed_response.key?('errors')
          raise MalformedError, "Malformed response: #{parsed_response['errors']}"
        end

        @data = parsed_response.fetch('data')
      end
    end
  end
end
