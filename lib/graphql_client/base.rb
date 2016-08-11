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
      end

      # Fetch a single object by global ID
      def find(id)
        global_id = GlobalID.new(id)
        type = @schema[global_id.model_name]
        ObjectProxy.new(type: type, client: self, id: id)
      end

      def method_missing(name, *_arguments)
        field = name.to_s
        type = @schema.query_root
        return simple_find(field) if type.fields.key? field
      end

      private

      def simple_find(type_name)
        type = @schema[type_name]
        ObjectProxy.new(type: type, client: self)
      end
    end
  end
end
