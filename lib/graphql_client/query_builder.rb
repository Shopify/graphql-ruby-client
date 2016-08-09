module GraphQL
  module Client
    class QueryBuilder
      def initialize(schema:)
        @schema = schema
      end

      def self.find(type, id)
        camel_case_model = type.name.camelize(:lower)
        pluralized = camel_case_model.pluralize
        fields = type.primitive_fields.keys.join(',')

        query = "query {
           #{camel_case_model}(id: \"#{id}\") {
             #{fields}
           }
         }"

        puts query
        query
      end

      def self.simple_find(type)
        camel_case_model = type.name.camelize(:lower)
        fields = type.primitive_fields.keys.join(',')

        query = "query {
           #{camel_case_model} {
             #{fields}
           }
         }"

        puts query
        query
      end

      def connection_from_object(root_type, root_id, field, return_type, per_page: 10, after: nil)
        camel_case_model = root_type.name.camelize(:lower)
        pluralized = return_type.name.camelize(:lower).pluralize
        fields = return_type.primitive_fields.keys.join(',')

        after.nil? ? after_stanza = '' : after_stanza = ", after: \"#{after}\""

        if @schema.query_root.field_arguments.key?(camel_case_model)
          if @schema.query_root.field_arguments[camel_case_model].find{|arg| arg.name == 'id'}
            root_id.nil? ? id_stanza = '' : id_stanza = "(id: \"#{root_id}\")"
          end
        end

        query = "
          query {
            #{root_type.name.camelize(:lower)}#{id_stanza} {
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

        puts query
        query
      end

      def self.list_from_object(root_type, root_id, field, return_type)
        fields = return_type.primitive_fields.keys.join(',')
        query = "
          query {
            #{root_type.name.camelize(:lower)}(id: \"#{root_id}\") {
              #{field} {
                #{fields}
              }
            }
          }"

        puts query
        query
      end
    end
  end
end
