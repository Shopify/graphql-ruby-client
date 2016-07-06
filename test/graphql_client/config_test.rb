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

      def test_initialize_parses_url_as_uri
        config = Config.new(url: 'http://example.com')

        assert_kind_of URI, config.url
      end

      def test_initialize_accepts_open_timeout_in_seconds
        config = Config.new(open_timeout: 2)
        assert_equal 2, config.open_timeout
      end

      def test_initialize_accepts_read_timeout_in_seconds
        config = Config.new(read_timeout: 5)
        assert_equal 5, config.read_timeout
      end

      def test_setting_open_timeout_after_initialization
        config = Config.new
        config.open_timeout = 2

        assert_equal 2, config.open_timeout
      end

      def test_setting_read_timeout_after_initialization
        config = Config.new
        config.read_timeout = 5

        assert_equal 5, config.read_timeout
      end

      def test_url_writer_coerces_to_uri
        config = Config.new
        config.url = 'http://example.com'

        assert_kind_of URI, config.url
      end
    end
  end
end
