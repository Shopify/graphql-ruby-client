module GraphQL
  module Client
    class Base
      attr_reader :schema, :url, :username, :password, :per_page, :headers, :debug

      def initialize(schema:, url:, username: '', password: '', per_page: 100, headers: {}, debug: false)
        @schema = schema
        @url = url
        @username = username
        @password = password
        @per_page = per_page
        @headers = headers
        @debug = debug
      end

      # Fetch a single object by global ID
      def find(id)
        global_id = GlobalID.new(id)
        type = @schema.type(global_id.model_name)
        request = Request.new(client: self, type: type)
        ObjectProxy.new(type: type, attributes: request.find(id).object, client: self)
      end

      def method_missing(name, *arguments)
        field = name.to_s
        type = @schema.query_root
        return all_from_connection(field) if type.connections.key? field
        return all_from_list(field) if type.lists.key? field
        return simple_find(field) if type.fields.key? field
      end

      private

      def simple_find(type_name)
        type = @schema.type(type_name)
        request = Request.new(client: self, type: type)
        ObjectProxy.new(type: type, attributes: request.simple_find(type_name).object, client: self)
      end
    end
  end
end
