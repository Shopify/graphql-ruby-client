require_relative '../test_helper'
require 'minitest/autorun'

class MerchantSchemaTest < Minitest::Test
  def test_loading_merchant_schema
    schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/merchant_schema.json')
    schema_string = File.read(schema_path)
    schema = GraphQL::Client::Schema.new(schema_string)

    product_type = schema.type('Product')

    expected_scalars = %w(bodyHtml
                          createdAt
                          handle
                          id
                          productType
                          publishedAt
                          templateSuffix
                          title
                          totalInventory
                          totalVariants
                          tracksInventory
                          updatedAt
                          vendor)

    expected_scalars.each do |name|
      assert_includes(product_type.scalars.keys, name)
    end
  end
end
