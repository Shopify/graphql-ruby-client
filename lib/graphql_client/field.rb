module GraphQL
  module Client
    class Field
      attr_reader :name, :type_name, :required, :type_kind, :arguments

      def initialize(field_data)
        @field_data = field_data
        @name = field_data['name']
        @type_name = normalize(parse_type(field_data))
        @type_kind = parse_kind
        @required = false
      end

      def add_argument(name, argument)
        @arguments[name] = argument
      end

      def connection?
        @type_kind == 'CONNECTION'
      end

      def interface?
        @type_kind == 'INTERFACE'
      end

      def list?
        @type_kind == 'LIST'
      end

      def object?
        @type_kind == 'OBJECT'
      end

      def scalar?
        @type_kind == 'SCALAR'
      end

      private

      def normalize(name)
        name.chomp('s').gsub(/Connection$/, '')
      end

      def parse_kind
        return @field_data['type']['kind'] unless @field_data['type']['ofType']

        if @field_data['type']['ofType']['name'].end_with? 'Connection'
          'CONNECTION'
        else
          @field_data['type']['ofType']['kind']
        end
      end

      def parse_type(field)
        return field if field.is_a? String
        return parse_type(field['type']) unless field['type'].nil?
        return parse_type(field['ofType']) unless field['ofType'].nil?

        field['name']
      end
    end
  end
end
