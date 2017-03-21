# frozen_string_literal: true

module GraphQL
  module Client
    module Adapters
      class HTTPAdapter
        JSON_MIME_TYPE = 'application/json'.freeze
        DEFAULT_HEADERS = { 'Accept' => JSON_MIME_TYPE, 'Content-Type' => JSON_MIME_TYPE }

        attr_reader :config

        def initialize(config)
          @config = config
        end

        def request(query, operation_name: nil, variables: {})
          req = build_request(query, operation_name: operation_name, variables: variables)

          response = Net::HTTP.start(config.url.hostname, config.url.port, use_ssl: https?) do |http|
            http.request(req)
          end

          case response
          when Net::HTTPOK then
            puts "Response body: \n#{JSON.pretty_generate(JSON.parse(response.body))}" if debug?
            Response.new(response.body)
          else
            raise ClientError, response
          end
        end

        private

        def build_request(query, operation_name: nil, variables: {})
          headers = DEFAULT_HEADERS.merge(config.headers)

          Net::HTTP::Post.new(config.url, headers).tap do |req|
            req.basic_auth(config.username, config.password)
            puts "Query: #{query}" if debug?

            req.body = {
              query: query,
              variables: variables,
              operation_name: operation_name,
            }.to_json
          end
        end

        def debug?
          config.debug
        end

        def https?
          config.url.scheme == 'https'
        end
      end
    end
  end
end
