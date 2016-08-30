module GraphQL
  module Client
    class QueryBuilder
      BLACKLISTED_FIELDS = %w(analyticsToken)
      def initialize(schema:)
        @schema = schema
      end

      def self.find(type, id)
        camel_case_model = type.camel_case_name
        fields = type.scalars.keys.join(',')

        "query {
           #{camel_case_model}(id: \"#{id}\") {
             #{fields}
           }
         }"
      end

      def self.simple_find(type)
        camel_case_model = type.camel_case_name
        field_names = type.scalars.keys - BLACKLISTED_FIELDS
        fields = field_names.join(',')

        "query {
           #{camel_case_model} {
             #{fields}
           }
         }"
      end

      def connection_from_object(root_type, root_id, field_name, return_type, after: nil, per_page:)
        camel_case_model = root_type.camel_case_name
        fields = return_type.scalars.keys.join(',')

        after_stanza = after.nil? ? '' : ", after: \"#{after}\""

        if @schema.query_root.field_arguments.key?(camel_case_model)
          if @schema.query_root.field_arguments[camel_case_model].find { |arg| arg.name == 'id' }
            id_stanza = root_id.nil? ? '' : "(id: \"#{root_id}\")"
          end
        end

        "query {
           #{camel_case_model}#{id_stanza} {
             #{camelize(field_name)}(first: #{per_page}#{after_stanza}) {
               pageInfo {
                 hasNextPage
               }
               edges {
                 cursor,
                 node {
                   #{fields}
                 }
               }
             }
           }
         }"
      end

      def self.list_from_object(root_type, root_id, field, return_type)
        camel_case_model = root_type.camel_case_name
        fields = return_type.scalars.keys.join(',')

        "query {
           #{camel_case_model}(id: \"#{root_id}\") {
             #{field} {
               #{fields}
             }
           }
         }"
      end

      def camelize(string)
        result = string.split('_').collect(&:capitalize).join
        result[0] = result[0].downcase
        result
      end
    end
  end
end
