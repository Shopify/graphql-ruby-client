module GraphQL
  module Client
    class QueryBuilder
      BLACKLISTED_FIELDS = %w(analyticsToken)
      def initialize(schema:, client: nil)
        @schema = schema
        @client = client
      end

      def self.simple_find(type)
        camel_case_model = camelize(type.name)
        scalars = type.fields.select { |_k, v| v.scalar? }
        field_names = scalars.keys - BLACKLISTED_FIELDS
        fields = field_names.join(',')

        "query {
           #{camel_case_model} {
             #{fields}
           }
         }"
      end

      def connection_from_object(root_type, root_id, field_name, return_type, after: nil, per_page:)
        if root_type.is_a? GraphQLSchema::Types::Connection
          root_type = root_type.node_type
        end

        real_return_type = return_type.edges.base_type.node.base_type
        scalars = real_return_type.fields.select { |_k, v| v.scalar? }

        query = @client.build_query
        args = {}
        if root_id && @schema.query_root.fields[root_type.name.downcase].args.key?('id')
          args['id'] = root_id
        end
        top_node = query.add_field(root_type.name.downcase, args)
        connection = top_node.add_connection(field_name, first: per_page, after: after)
        connection.add_fields(*scalars.keys)

        query.to_s
      end

      def self.list_from_object(root_type, root_id, field, return_type)
        camel_case_model = camelize(root_type.name)
        fields = return_type.scalars.keys.join(',')

        "query {
           #{camel_case_model}(id: \"#{root_id}\") {
             #{field} {
               #{fields}
             }
           }
         }"
      end

      def self.camelize(string)
        result = string.split('_').collect(&:capitalize).join
        result[0] = result[0].downcase
        result
      end
    end
  end
end
