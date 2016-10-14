# frozen_string_literal: true

module GraphQL
  module Client
    class Config
      attr_accessor :debug, :fetch_all_pages, :headers, :per_page, :password, :username, :url

      DEFAULTS = {
        debug: false,
        fetch_all_pages: true,
        headers: {},
        per_page: 100,
      }

      def initialize(options = {})
        @options = DEFAULTS.merge(options)
        @debug = @options[:debug]
        @fetch_all_pages = @options[:fetch_all_pages]
        @headers = @options[:headers]
        @per_page = @options[:per_page]
        @password = @options[:password]
        @username = @options[:username]
        @url = URI(@options[:url]) if @options[:url]
      end

      def url=(url)
        @url = URI(url)
      end
    end
  end
end
