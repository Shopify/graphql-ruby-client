module GraphQL
  module Client
    class QueryBuilder
      BLACKLISTED_FIELDS = %w(analyticsToken)

      def initialize(schema)
        @schema = schema
      end

      def for_field(field)
        type = field.base_type
        camel_case_model = camelize(type.name)

        query = Query::QueryOperation.new(@schema) do |q|
          q.add_field(camel_case_model) do |field|
            type.scalar_fields.each do |name, subfield|
              field.add_field(subfield.name) unless BLACKLISTED_FIELDS.include?(subfield.name)
            end
          end
        end

        query.to_query
      end

      def connection_from_object(root_type, root_id, field, after: nil, per_page:, parent_field:)
        if root_type.is_a? GraphQLSchema::Types::Connection
          root_type = root_type.node_type
        end

        return_type = field.base_type.edges.base_type.node.base_type # Good god
        scalars = return_type.fields.scalars

        query = Query::QueryOperation.new(@schema)

        args = {}

        if root_id && @schema.query_root.fields[root_type.name.downcase].args.key?('id')
          args['id'] = root_id
        end

        query.add_field(root_type.name.downcase, args) do |node|
          node.add_connection(field.name, first: per_page, after: after) do |connection|
            connection.add_fields(*scalars.names)
          end
        end

        query.to_query
      end

      private

      def camelize(string)
        result = string.split('_').collect(&:capitalize).join
        result[0] = result[0].downcase
        result
      end
    end
  end
end
