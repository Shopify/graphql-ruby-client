require 'test_helper'

module GraphQL
  module Client
    module Query
      class ArgumentTest < Minitest::Test
        def test_to_query_formats_arguments
          arguments = Argument.new(2)

          assert_equal '2', arguments.to_query
        end

        def test_to_query_quotes_string_values
          arguments = Argument.new('2')

          assert_equal '"2"', arguments.to_query
        end

        def test_to_query_boolean
          arguments = Argument.new(true)

          assert_equal 'true', arguments.to_query
        end

        def test_to_query_array
          arguments = Argument.new([1, 'two'])

          assert_equal '[1, "two"]', arguments.to_query
        end

        def test_to_query_hash
          arguments = Argument.new(name: 'Foo', ids: [1, 2])

          assert_equal '{ name: "Foo", ids: [1,2] }', arguments.to_query
        end

        def test_to_query_float
          arguments = Argument.new(4.7e-24)

          assert_equal '4.7e-24', arguments.to_query
        end

        def test_to_query_escapes_control_characters
          arguments = Argument.new("control\ncharacter")

          assert_equal '"control\\ncharacter"', arguments.to_query
        end

        def test_to_query_unicode
          arguments = Argument.new('☀︎🏆 ¶')

          assert_equal '"☀︎🏆 ¶"', arguments.to_query
        end

        def test_to_query_escaped_unicode
          arguments = Argument.new("\u0012")

          assert_equal '"\\u0012"', arguments.to_query
        end

        def test_to_query_escapes_characters
          arguments = Argument.new("foo\"bar")

          assert_equal '"foo\"bar"', arguments.to_query
        end
      end
    end
  end
end
