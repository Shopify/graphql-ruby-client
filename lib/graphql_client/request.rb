require 'uri'

module GraphQL
  module Client
    class QueryError < StandardError; end
    class SchemaError < StandardError; end

    class Request
      attr_reader :type

      def initialize(client: client, per_page: 10, type: nil)
        @client = client
        @per_page = per_page
        @type = type
      end

      def from_query(query)
        response_body = send_request(query)
        Response.new(self, response_body)
      end

      def send_request(query)
        req = Net::HTTP::Post.new(@client.url)
        parsed_url = URI.parse(@client.url)

        req.basic_auth(@client.username, @client.password)
        req['Accept'] = 'application/json'
        req['Content-Type'] = 'application/json'

        body = { query: query, variables: {} }.to_json
        req.body = body

        response = Net::HTTP.start(parsed_url.hostname, parsed_url.port, use_ssl: parsed_url.scheme == 'https') {|http|
          http.request(req)
        }

        puts "Response body: \n#{response.body}"
        response.body
      end

      # Move these to the base client and only use Request#from_query
      def find(id)
        query = QueryBuilder.find(@type, id)
        Response.new(self, send_request(query))
      end

      def simple_find(type_name)
        query = QueryBuilder.simple_find(@client.schema.types[type_name])
        Response.new(self, send_request(query))
      end
    end
  end
end
