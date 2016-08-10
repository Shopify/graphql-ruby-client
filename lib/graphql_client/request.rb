require 'uri'

module GraphQL
  module Client
    class NetworkError < StandardError; end
    class SchemaError < StandardError; end

    class Request
      attr_reader :type

      def initialize(client:, type: nil)
        @client = client
        @type = type
      end

      def from_query(query)
        puts "Query: #{query}" if @client.debug
        response_body = send_request(query)
        Response.new(self, response_body)
      end

      def send_request(query)
        req = Net::HTTP::Post.new(@client.url)
        parsed_url = URI.parse(@client.url)

        req.basic_auth(@client.username, @client.password)
        req['Accept'] = 'application/json'
        req['Content-Type'] = 'application/json'

        @client.headers.each do |key, value|
          req[key] = value
        end

        body = { query: query, variables: {} }.to_json
        req.body = body

        response = Net::HTTP.start(parsed_url.hostname, parsed_url.port, use_ssl: parsed_url.scheme == 'https') do |http|
          http.request(req)
        end

        unless response.code == '200'
          raise NetworkError, "Response error - #{response.code}/#{response.message}"
        end

        puts "Response body: \n#{response.body}" if @client.debug
        response.body
      end

      # Move these to the base client and only use Request#from_query
      def find(id)
        query = QueryBuilder.find(@type, id)
        puts "Query: #{query}" if @client.debug
        Response.new(self, send_request(query))
      end

      def simple_find(type_name)
        query = QueryBuilder.simple_find(@client.schema.type(type_name))
        puts "Query: #{query}" if @client.debug
        Response.new(self, send_request(query))
      end
    end
  end
end
