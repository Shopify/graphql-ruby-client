# frozen_string_literal: true

module GraphQL
  module Client
    Error = Class.new(StandardError)
    OpenTimeoutError = Class.new(Error)
    ReadTimeoutError = Class.new(Error)
    ResponseError = Class.new(Error)

    class ClientError < Error
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def message
        "#{response.code} #{response.message}"
      end
    end
  end
end
