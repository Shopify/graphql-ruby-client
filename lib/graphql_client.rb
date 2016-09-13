require 'rubygems'
require 'bundler/setup'
require 'graphql_schema'
require 'graphql_client/http_client.rb'
require 'graphql_client/query/selection_set.rb'
require 'graphql_client/query/argument.rb'
require 'graphql_client/query/query_field.rb'
require 'graphql_client/query/operation.rb'
require 'graphql_client/query/query_operation.rb'
require 'graphql_client/query/mutation_operation.rb'
require 'graphql_client/request.rb'
require 'graphql_client/connection_proxy.rb'
require 'graphql_client/response.rb'
require 'graphql_client/object_proxy.rb'
require 'graphql_client/introspection_query.rb'

module GraphQL
  module Client
    class << self
      def new(schema:, url:, username: '', password: '', per_page: 100, headers: {}, debug: false)
        HTTPClient.new(
          schema: schema,
          url: url,
          username: username,
          password: password,
          per_page: per_page,
          headers: headers,
          debug: debug
        )
      end
    end
  end
end
