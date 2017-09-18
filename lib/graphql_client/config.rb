# frozen_string_literal: true

module GraphQL
  module Client
    class Config
      attr_accessor(
        :debug,
        :headers,
        :per_page,
        :password,
        :username,
        :url,
        :open_timeout,
        :read_timeout
      )

      DEFAULTS = {
        debug: false,
        headers: {},
        per_page: 100,
      }

      def initialize(options = {})
        @options = DEFAULTS.merge(options)
        @debug = @options[:debug]
        @headers = @options[:headers]
        @per_page = @options[:per_page]
        @password = @options[:password]
        @username = @options[:username]
        @open_timeout = @options[:open_timeout]
        @read_timeout = @options[:read_timeout]
        @url = URI(@options[:url]) if @options[:url]
      end

      def url=(url)
        @url = URI(url)
      end
    end
  end
end
