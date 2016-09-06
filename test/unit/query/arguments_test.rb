require 'test_helper'

module GraphQL
  module Client
    module Query
      class ArgumentsTest < Minitest::Test
        def test_to_query_formats_arguments
          arguments = Arguments.new(id: 2)

          assert_equal '(id: 2)', arguments.to_query
        end

        def test_to_query_quotes_string_values
          arguments = Arguments.new(id: '2')

          assert_equal '(id: "2")', arguments.to_query
        end

        def test_to_query_handles_multiple_arguments
          arguments = Arguments.new(id: '2', name: 'Foo')

          assert_equal '(id: "2", name: "Foo")', arguments.to_query
        end
      end
    end
  end
end
