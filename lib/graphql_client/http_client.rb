module GraphQL
  module Client
    class HTTPClient
      attr_reader :schema, :url, :username, :password, :per_page, :headers, :debug

      def initialize(schema:, url:, username: '', password: '', per_page: 100, headers: {}, debug: false)
        @schema = schema
        @url = URI(url)
        @username = username
        @password = password
        @per_page = per_page
        @headers = headers
        @debug = debug

        define_field_accessors
      end

      def build_query
        query = Query::QueryOperation.new(@schema)

        if block_given?
          yield query
        else
          query
        end
      end

      def query(query)
        req = Request.new(self)
        req.send_request(query.to_query)
      end

      def raw_query(query_string)
        req = Request.new(self)
        req.send_request(query_string)
      end

      private

      def define_field_accessors
        query_root = @schema.query_root
        fields = query_root.fields.scalars + query_root.fields.objects

        fields.each do |name, field|
          define_singleton_method(name) do |**arguments|
            ObjectProxy.new(field: field, client: self, **arguments)
          end
        end
      end
    end
  end
end
