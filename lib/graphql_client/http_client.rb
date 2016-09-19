module GraphQL
  module Client
    class HTTPClient
      attr_reader :config, :schema

      def initialize(schema, config: nil, &block)
        @config = config || Config.new
        @schema = schema

        define_field_accessors

        instance_eval(&block) if block_given?
      end

      def build_query
        query = Query::QueryOperation.new(@schema)

        if block_given?
          yield query
        else
          query
        end
      end

      def configure
        yield @config
      end

      def query(query)
        req = Request.new(config)
        req.send_request(query.to_query)
      end

      def raw_query(query_string)
        req = Request.new(config)
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
