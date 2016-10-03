module GraphQL
  module Client
    class Base
      attr_reader :adapter, :config, :schema

      def initialize(schema, config: nil, adapter: nil, &block)
        @config = config || Config.new
        @schema = schema
        @adapter = adapter || Adapters::HTTPAdapter.new(@config)

        define_field_accessors

        instance_eval(&block) if block_given?
      end

      def build_query
        query = Query::Document.new(@schema)

        if block_given?
          yield query
        else
          query
        end
      end

      def configure
        yield @config
      end

      def query(query, operation_name: nil)
        adapter.request(query.to_query, operation_name: operation_name)
      end

      def raw_query(query_string, operation_name: nil)
        adapter.request(query_string, operation_name: operation_name)
      end

      private

      def define_field_accessors
        query_root = @schema.query_root
        fields_to_define = query_root.fields.scalars + query_root.fields.objects

        fields_to_define.each do |name, field|
          define_singleton_method(name) do |*fields, **arguments|
            ObjectProxy.new(*fields, field: field, client: self, **arguments)
          end
        end
      end
    end
  end
end
