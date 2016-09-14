require 'test_helper'

class MerchantChannelTest < Minitest::Test
  URL = 'https://big-and-tall-for-pets.myshopify.com/admin/api/graphql.json'

  def setup
    WebMock.allow_net_connect!

    schema_string = File.read(fixture_path('merchant_schema.json'))
    @schema = GraphQLSchema.new(schema_string)

    @client = GraphQL::Client.new(@schema) do
      configure do |c|
        c.url = URL
        c.headers = { 'X-Shopify-Access-Token': ENV.fetch('MERCHANT_TOKEN') }
      end
    end
  end

  def test_public_access_tokens
    public_access_tokens = @client.shop.public_access_tokens(fields: ['title'])
    assert public_access_tokens.count.positive?

    new_token = public_access_tokens.create(title: 'Test')
    assert_equal 32, new_token.access_token.length
    assert_equal 'Test', new_token.title

    new_token.destroy
  end
end
