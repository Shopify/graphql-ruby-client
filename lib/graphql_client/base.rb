module GraphQL
  module Client
    class Base
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

      private

      def define_field_accessors
        @schema.query_root.fields.keys.each do |name|
          define_singleton_method(name) do
            type = @schema[name]
            ObjectProxy.new(type: type, client: self)
          end
        end
      end
    end
  end
end
