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

URL = 'https://big-and-tall-for-pets.myshopify.com/api/graph'
USERNAME = '692d1d26c49c56f4a217d0fbd8014768'
