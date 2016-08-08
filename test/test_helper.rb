require 'pry'
require 'json'
require 'vcr'
# require 'webmock/minitest'

require 'simplecov'
SimpleCov.start

require 'graphql_client'

# VCR.configure do |config|
#   config.cassette_library_dir = "fixtures/vcr_cassettes"
#   config.hook_into :webmock
# end
