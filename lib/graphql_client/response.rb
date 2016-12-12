module GraphQL
  module Client
    class Response
      ResponseError = Class.new(StandardError)

      attr_reader :body, :data, :errors, :extensions

      def initialize(response_body)
        response = JSON.parse(response_body)
        data, errors, extensions = response.values_at('data', 'errors', 'extensions')

        raise ResponseError, errors if !data && errors

        @body = response
        @data = data
        @errors = errors.to_a
        @extensions = extensions.to_a
      end
    end
  end
end
