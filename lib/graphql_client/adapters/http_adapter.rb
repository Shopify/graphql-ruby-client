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

          http_options = {
            use_ssl: https?,
            open_timeout: config.open_timeout,
            read_timeout: config.read_timeout
          }

          # IMPORTANT: open_timeout is only respected when it's supplied as part of the options
          # when you call Net::HTTP.start. It is not respected when it's set inside the block of
          # Net::HTTP.start (i.e. http.open_timeout = 1)
          response = Net::HTTP.start(config.url.hostname, config.url.port, http_options) do |http|
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
