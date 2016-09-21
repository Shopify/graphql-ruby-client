require 'test_helper'

module GraphQL
  module Client
    module Query
      class AddInlineFragmentTest < Minitest::Test
        def setup
          schema_string = File.read(fixture_path('merchant_schema.json'))
          @schema = GraphQLSchema.new(schema_string)
          @document = Document.new(@schema)

          field = @schema.query_root.fields.fetch('shop')
          @query_field = QueryField.new(field, document: @document, arguments: {})
        end

        def test_add_inline_fragment_yields_inline_fragment
          inline_fragment_object = nil

          inline_fragment = @query_field.add_inline_fragment('Shop') do |f|
            inline_fragment_object = f
          end

          assert_equal inline_fragment_object, inline_fragment
        end

        def test_add_inline_fragment_creates_inline_fragment_with_explicit_type
          inline_fragment = @query_field.add_inline_fragment('Shop')

          assert_equal @schema['Shop'], inline_fragment.type
          assert_equal [inline_fragment], @query_field.selection_set
        end

        def test_add_inline_fragment_creates_inline_fragment_with_explicit_interface_type
          inline_fragment = @query_field.add_inline_fragment('Node')

          assert_equal @schema['Node'], inline_fragment.type
          assert_equal [inline_fragment], @query_field.selection_set
        end

        def test_add_inline_fragment_creates_inline_fragment_with_implicit_type
          inline_fragment = @query_field.add_inline_fragment

          assert_equal @schema['Shop'], inline_fragment.type
          assert_equal [inline_fragment], @query_field.selection_set
        end

        def test_add_inline_fragment_raises_exception_for_invalid_target_type
          assert_raises AddInlineFragment::INVALID_FRAGMENT_TARGET do |e|
            @query_field.add_inline_fragment('Image')

            assert_equal "invalid target type 'Image' for fragment of type 'Shop'", e.message
          end
        end
      end
    end
  end
end
