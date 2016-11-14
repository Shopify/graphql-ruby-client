module GraphQL
  module Client
    module Query
      module AddInlineFragment
        INVALID_FRAGMENT_TARGET = Class.new(StandardError)

        def add_inline_fragment(type_name = resolver_type.name)
          target_type = validate_fragment_target(document.schema[type_name])

          inline_fragment = InlineFragment.new(target_type, document: document)
          selection_set.add_inline_fragment(inline_fragment)

          if block_given?
            yield inline_fragment
          else
            inline_fragment
          end
        end

        private

        def validate_fragment_target(type)
          if resolver_type.name != type.name && !resolver_type.possible_types.keys.include?(type.name)
            raise INVALID_FRAGMENT_TARGET,
              "invalid target type '#{type.name}' for fragment of type #{resolver_type.name}"
          else
            type
          end
        end
      end
    end
  end
end
