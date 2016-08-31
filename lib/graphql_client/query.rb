module GraphQL
  module Client
    QueryError = Class.new(StandardError)

    class Query
      def initialize(schema:, type: nil)
        @schema = schema
        @type = type
        @field = nil
        @fields = []
        @type = @schema.query_root if type.nil?
      end

      def add_field(field_name, arguments = {})
        resolved_field = resolve_field(field_name)
        field_query = FieldQuery.new(schema: @schema, parent: self, field: resolved_field, arguments: arguments)
        @fields << field_query
        field_query
      end

      def add_fields(*fields)
        fields.each do |field|
          add_field(field)
        end
      end

      def resolve_field(field_name)
        resolved_field = if @type.respond_to?(:node_type)
          @type.node_type.fields[field_name]
        else
          @type.fields[field_name]
        end

        unless resolved_field
          raise QueryError, "Could not resolve field #{field_name} on type #{@type.name}"
        end

        resolved_field
      end

      def serialize_arguments(arguments)
        result = ''
        arguments = arguments.reject { |_, value| value.nil? }
        if arguments.any?
          result += '('
          arguments.each do |name, value|
            result += if value.is_a? Integer
              "#{name}: #{value}"
            else
              "#{name}: \"#{value}\""
            end

            result += ','
          end
          result += ' )'
        end

        result
      end

      def to_s
        "{#{@fields.join('')}}" if @fields.any?
      end
    end

    class ConnectionFieldQuery < Query
      def initialize(schema:, parent:, field:, arguments: {})
        @schema = schema
        @parent = parent
        @field = field
        @fields = []
        @type = field.base_type
        @arguments = arguments
      end

      def to_s
        result = @field.name + serialize_arguments(@arguments)
        result += ' { pageInfo { hasNextPage } edges { cursor node '
        result += "{#{@fields.join(' ')}}" if @fields.any?
        result += '} }'
        result
      end

      def add_field(field_name, _arguments = {})
        resolved_field = resolve_field(field_name)
        field_query = FieldQuery.new(schema: @schema, parent: self, field: resolved_field)
        @fields << field_query
        field_query
      end
    end

    class FieldQuery < Query
      def initialize(schema:, parent:, field:, arguments: {})
        @schema = schema
        @parent = parent
        @field = field
        @fields = []
        @type = field.base_type
        @arguments = arguments
      end

      def add_connection(field_name, arguments = {})
        resolved_field = resolve_field(field_name)
        field_query = ConnectionFieldQuery.new(schema: @schema, parent: self,
                                               field: resolved_field, arguments: arguments)
        @fields << field_query
        field_query
      end

      def add_field(field_name)
        resolved_field = resolve_field(field_name)
        field_query = FieldQuery.new(schema: @schema, parent: self, field: resolved_field)
        @fields << field_query
        field_query
      end

      def to_s
        result = @field.name
        result += serialize_arguments(@arguments)

        if @fields.any?
          result += '{'
          @fields.each do |field|
            result += field.to_s + ' '
          end
          result += '}'
        end

        result
      end
    end
  end
end
