# frozen_string_literal: true

module GraphQL
  module Client
    class Response
      attr_reader :body, :data, :errors, :extensions

      def initialize(response_body)
        response = JSON.parse(response_body)
        data, errors, extensions = response.values_at('data', 'errors', 'extensions')

        raise ResponseError, errors if !data && errors

        @body = response
        @data = data
        @errors = errors.to_a
        @extensions = extensions
      end
    end
  end
end
