require_relative '../test_helper'
require 'minitest/autorun'

class MerchantChannelTest < Minitest::Test
  URL = 'https://big-and-tall-for-pets.myshopify.com/admin/api/graphql.json'
  SECRET = '5d62605439df48d903dcd6b3a2cadebf'

  def setup
    schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/merchant_schema.json')
    schema_string = File.read(schema_path)

    @schema = GraphQL::Client::Schema.new(schema_string)
    @client = GraphQL::Client::Base.new(
      schema: @schema,
      url: URL,
      headers: {
        'X-Shopify-Access-Token': SECRET
      }
    )
  end

  def test_public_access_tokens
    public_access_tokens = @client.shop.public_access_tokens
    new_token = public_access_tokens.create(title: 'Test')

    assert_equal 32, new_token.access_token.length
    assert_equal 'Test', new_token.title

    new_token.destroy
  end
end
