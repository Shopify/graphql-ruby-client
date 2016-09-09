module GraphQL
  module Client
    class QueryBuilder
      BLACKLISTED_FIELDS = %w(analyticsToken)

      def initialize(schema)
        @schema = schema
      end

      def simple_find(type)
        camel_case_model = self.class.camelize(type.name)
        field_names = type.scalar_fields.names - BLACKLISTED_FIELDS

        query = Query::QueryOperation.new(@schema) do |q|
          q.add_field(camel_case_model) do |field|
            field.add_fields(*field_names)
          end
        end

        query.to_query
      end

      def connection_from_object(root_type, root_id, field_name, return_type, after: nil, per_page:)
        if root_type.is_a? GraphQLSchema::Types::Connection
          root_type = root_type.node_type
        end

        real_return_type = return_type.edges.base_type.node.base_type
        scalars = real_return_type.fields.scalars

        query = Query::QueryOperation.new(@schema)

        args = {}

        if root_id && @schema.query_root.fields[root_type.name.downcase].args.key?('id')
          args['id'] = root_id
        end

        query.add_field(root_type.name.downcase, args) do |node|
          node.add_connection(field_name, first: per_page, after: after) do |connection|
            connection.add_fields(*scalars.names)
          end
        end

        query.to_query
      end

      def self.camelize(string)
        result = string.split('_').collect(&:capitalize).join
        result[0] = result[0].downcase
        result
      end
    end
  end
end
