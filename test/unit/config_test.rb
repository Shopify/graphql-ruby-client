require 'test_helper'

module GraphQL
  module Client
    class ConfigTest < Minitest::Test
      def test_initialize_overrides_defaults
        config = Config.new(
          debug: true,
          password: 'foo',
          per_page: 5,
        )

        assert config.debug
        assert_equal({}, config.headers)
        assert_equal 'foo', config.password
        assert_equal 5, config.per_page
        assert_nil config.username
      end

      def test_initialize_parses_url_as_URI
        config = Config.new(url: 'http://example.com')

        assert_kind_of URI, config.url
      end

      def test_url_writer_coerces_to_URI
        config = Config.new
        config.url = 'http://example.com'

        assert_kind_of URI, config.url
      end
    end
  end
end
