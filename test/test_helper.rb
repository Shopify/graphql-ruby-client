require 'json'
require 'graphql'
require 'pry'
require 'simplecov'
require 'webmock/minitest'

SimpleCov.start

require 'graphql_client'
require 'minitest/autorun'

def fixture_path(name)
  File.join(__dir__, '/support/fixtures', name)
end

class Minitest::Test
  def assert_valid_query(query_string, schema, operation_name: nil, variables: {})
    query = GraphQL::Query.new(
      schema,
      query_string,
      max_depth: 10,
      max_complexity: 1000,
      operation_name: operation_name,
      variables: variables,
    )

    assert query.valid?, "Query is not valid. Validation errors:\n" + query.validation_errors.to_s
  end
end
