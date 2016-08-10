module GraphQL
  module Client
    class Type
      PRIMITIVES = %w(
        Boolean
        DateTime
        ID
        Int
        String
      )

      attr_reader :fields, :lists, :objects, :connections, :name, :field_arguments

      def initialize(name, type)
        @name = name
        @type = type
        @fields = {}
        @objects = {}
        @connections = {}
        @lists = {}
        @field_arguments = {}

        unless @type['fields'].nil?
          @type['fields'].each do |field|
            if field.key?('args')
              unless field['args'].empty?
                @field_arguments[field['name']] = []
                field['args'].each do |argument|
                  @field_arguments[field['name']] << GraphQL::Client::Argument.new(argument['name'], argument['description'])
                end
                if field.fetch('type', {}).fetch('ofType', nil).nil?
                  # puts "Node detected for #{field['name']}"
                  next
                else
                  if field.fetch('type', {}).fetch('ofType', {}).fetch('name', '').end_with? 'Connection'
                    @connections[field['name']] = determine_type(field['type'])
                    next
                  else
                    type = determine_type(field['type'])
                    @lists[field['name']] = type
                    next
                  end
                end
              end
            end

            unless field['type']['ofType'].nil?
              kind = field['type']['ofType']['kind']
            end

            if kind == 'LIST'
              @objects[field['name']] = kind
            else
              # Non-null types are wrapped in two layers
              type_name = if field['type'].fetch('ofType').nil?
                field['type']['name']
              else
                field['type']['ofType']['name']
              end

              @fields[field['name']] = Field.new(field['name'], type_name, false)
            end
          end
        end
      end

      def connection?(field)
        @connections.key? camel_case(field)
      end

      def list?(field)
        @lists.key? camel_case(field)
      end

      def field?(field)
        @fields.key? camel_case(field)
      end

      def object?(field)
        @objects.key? camel_case(field)
      end

      def camel_case(string)
        string = string.replace(string.split("_").each_with_index { |s, i| s.capitalize! unless i == 0 }.join(""))
        string[0] = string[0].downcase
        string
      end

      def camel_case_name
        camel_case(@name)
      end

      def determine_type(type)
        return type if type.is_a? String

        if type.key?('ofType')
          return determine_type(type['ofType']) unless type['ofType'].nil?
        end

        type['name']
      end

      def primitive_fields
        @fields.select { |_name, field| PRIMITIVES.include? field.type_name }
      end
    end
  end
end
