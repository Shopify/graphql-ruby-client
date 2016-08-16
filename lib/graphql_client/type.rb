module GraphQL
  module Client
    class Type
      attr_reader :field_arguments, :fields, :name

      def initialize(name, type)
        @field_arguments = {}
        @name = name
        @type = type
        @fields = {}

        unless @type['fields'].nil?
          @type['fields'].each do |field|
            unless field['args'].empty?
              @field_arguments[field['name']] = []
              field['args'].each do |argument|
                @field_arguments[field['name']] << Argument.new(argument['name'], argument['description'])
              end
            end

            new_field = Field.new(field)
            @fields[new_field.name] = new_field
          end
        end
      end

      def connections
        @fields.select { |_name, field| field.connection? }
      end

      def interfaces
        @fields.select { |_name, field| field.interface? }
      end

      def lists
        @fields.select { |_name, field| field.list? }
      end

      def objects
        @fields.select { |_name, field| field.object? }
      end

      def scalars
        @fields.select { |_name, field| field.scalar? }
      end

      def camel_case(string)
        string = string.replace(string.split("_").each_with_index do |s, i|
          s.capitalize! unless i.zero?
        end.join(""))

        string[0] = string[0].downcase
        string
      end

      def camel_case_name
        camel_case(@name)
      end
    end
  end
end
