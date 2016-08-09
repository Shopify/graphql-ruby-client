require_relative '../test_helper'
require 'minitest/autorun'

class MerchantSchemaTest < Minitest::Test
  def test_loading_merchant_schema
    schema_path = File.join(File.dirname(__FILE__), '../support/fixtures/merchant_schema.json')
    schema_string = File.read(schema_path)

    schema = GraphQL::Client::Schema.new(schema_string)
    assert !schema.types.empty?

    product_type = schema.types['Product']

    expected_fields = %w(bodyHtml
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

    expected_fields.each do |field|
      assert_includes(product_type.fields.keys, field)
    end
  end
end
