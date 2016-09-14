require 'rubygems'
require 'bundler/setup'
require 'json'
require 'graphql_schema'

require 'graphql_client/config.rb'
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
      def new(schema, config: nil, &block)
        HTTPClient.new(schema, config: config, &block)
      end
    end
  end
end
