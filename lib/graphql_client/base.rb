require 'global_id'

module GraphQL
  module Client
    class Base
      attr_reader :schema, :url, :username, :password, :per_page, :headers

      def initialize(schema:, url:, username: '', password: '', per_page: 10, headers: {})
        @schema = schema
        @url = url
        @username = username
        @password = password
        @per_page = per_page
        @headers = headers
      end

      # Fetch a single object by global ID
      def find(id)
        begin
          global_id = GlobalID.new(id)
        rescue URI::BadURIError
          return simple_find(id)
        end

        type = @schema.types[global_id.model_name]
        request = Request.new(client: self, type: type)
        ObjectProxy.new(type: type, properties: request.find(id).object, client: self)
      end

      private

      def simple_find(type_name)
        type = @schema.types[type_name]
        request = Request.new(client: self, type: type)
        ObjectProxy.new(type: type, properties: request.simple_find(type_name).object, client: self)
      end
    end
  end
end
