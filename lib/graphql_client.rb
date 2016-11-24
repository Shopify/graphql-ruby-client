require 'rubygems'
require 'bundler/setup'
require 'json'
require 'graphql_schema'

require 'graphql_client/config.rb'
require 'graphql_client/adapters/http_adapter.rb'
require 'graphql_client/base.rb'
require 'graphql_client/query/has_selection_set.rb'
require 'graphql_client/query/add_inline_fragment.rb'
require 'graphql_client/query/selection_set.rb'
require 'graphql_client/query/fragment.rb'
require 'graphql_client/query/inline_fragment.rb'
require 'graphql_client/query/argument.rb'
require 'graphql_client/query/query_field.rb'
require 'graphql_client/query/query_document.rb'
require 'graphql_client/query/mutation_document.rb'
require 'graphql_client/query/document.rb'
require 'graphql_client/query/operation.rb'
require 'graphql_client/query/operations/query_operation.rb'
require 'graphql_client/query/operations/mutation_operation.rb'
require 'graphql_client/connection_proxy.rb'
require 'graphql_client/response.rb'
require 'graphql_client/graph_object.rb'
require 'graphql_client/graph_connection.rb'
require 'graphql_client/graph_node.rb'
require 'graphql_client/object_proxy.rb'
require 'graphql_client/introspection_query.rb'

module GraphQL
  module Client
    class << self
      def new(schema, config: nil, adapter: nil, &block)
        Base.new(schema, config: config, adapter: adapter, &block)
      end
    end
  end
end
