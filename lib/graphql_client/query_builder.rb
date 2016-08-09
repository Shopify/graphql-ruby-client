module GraphQL
  module Client
    class QueryBuilder
      def initialize(schema:)
        @schema = schema
      end

      def self.find(type, id)
        camel_case_model = type.camel_case_name
        fields = type.primitive_fields.keys.join(',')

        "query {
           #{camel_case_model}(id: \"#{id}\") {
             #{fields}
           }
         }"
      end

      def self.simple_find(type)
        camel_case_model = type.camel_case_name
        fields = type.primitive_fields.keys.join(',')

        "query {
           #{camel_case_model} {
             #{fields}
           }
         }"
      end

      def connection_from_object(root_type, root_id, _field, return_type, per_page: 10, after: nil)
        camel_case_model = root_type.camel_case_name
        pluralized = return_type.camel_case_name  + 's'
        fields = return_type.primitive_fields.keys.join(',')

        after_stanza = after.nil? ? '' : ", after: \"#{after}\""

        if @schema.query_root.field_arguments.key?(camel_case_model)
          if @schema.query_root.field_arguments[camel_case_model].find { |arg| arg.name == 'id' }
            id_stanza = root_id.nil? ? '' : "(id: \"#{root_id}\")"
          end
        end

        "query {
           #{camel_case_model}#{id_stanza} {
             #{pluralized}(first: #{per_page}#{after_stanza}) {
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
        fields = return_type.primitive_fields.keys.join(',')

        "query {
           #{camel_case_model}(id: \"#{root_id}\") {
             #{field} {
               #{fields}
             }
           }
         }"
      end
    end
  end
end
