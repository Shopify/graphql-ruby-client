require 'uri'

module GraphQL
  module Client
    JSON_MIME_TYPE = 'application/json'.freeze
    DEFAULT_HEADERS = { 'Accept' => JSON_MIME_TYPE, 'Content-Type' => JSON_MIME_TYPE }

    NetworkError = Class.new(StandardError)

    class Request
      def initialize(client)
        @client = client
      end

      def send_request(query)
        req = build_request(query)

        response = Net::HTTP.start(@client.url.hostname, @client.url.port, use_ssl: https?) do |http|
          http.request(req)
        end

        case response
        when Net::HTTPOK then
          puts "Response body: \n#{response.body}" if @client.debug
          Response.new(response.body)
        else
          raise NetworkError, "Response error: #{response.code}/#{response.message}"
        end
      end

      private

      def build_request(query)
        headers = DEFAULT_HEADERS.merge(@client.headers)

        Net::HTTP::Post.new(@client.url, headers).tap do |req|
          req.basic_auth(@client.username, @client.password)
          puts "Query: #{query}" if @client.debug
          req.body = { query: query, variables: {} }.to_json
        end
      end

      def https?
        @client.url.scheme == 'https'
      end
    end
  end
end
