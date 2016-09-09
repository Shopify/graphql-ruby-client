require 'pry'
require 'json'
require 'simplecov'
require 'spy/integration'

SimpleCov.start

require 'graphql_client'
require 'minitest/autorun'

def fixture_path(name)
  File.join(__dir__, '/support/fixtures', name)
end
