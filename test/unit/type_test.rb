require_relative '../test_helper'
require 'minitest/autorun'

class TypeTest < Minitest::Test
  def test_query_root
    query_root =
      { "kind" => "OBJECT",
        "name" => "QueryRoot",
        "description" => nil,
        "fields" =>
        [{ "name" => "collection",
           "description" => nil,
           "args" =>
           [{ "name" => "id",
              "description" => nil,
              "type" =>
              { "kind" => "NON_NULL",
                "name" => "Non-Null",
                "ofType" => { "kind" => "SCALAR", "name" => "ID", "ofType" => nil } },
              "defaultValue" => nil }],
           "type" => { "kind" => "OBJECT", "name" => "Collection", "ofType" => nil },
           "isDeprecated" => false,
           "deprecationReason" => nil },
         { "name" => "customer",
           "description" => nil,
           "args" =>
           [{ "name" => "id",
              "description" => nil,
              "type" =>
              { "kind" => "NON_NULL",
                "name" => "Non-Null",
                "ofType" => { "kind" => "SCALAR", "name" => "ID", "ofType" => nil } },
              "defaultValue" => nil }],
           "type" => { "kind" => "OBJECT", "name" => "Customer", "ofType" => nil },
           "isDeprecated" => false,
           "deprecationReason" => nil },
         { "name" => "fulfillment",
           "description" => nil,
           "args" =>
           [{ "name" => "id",
              "description" => nil,
              "type" =>
              { "kind" => "NON_NULL",
                "name" => "Non-Null",
                "ofType" => { "kind" => "SCALAR", "name" => "ID", "ofType" => nil } },
              "defaultValue" => nil }],
           "type" => { "kind" => "OBJECT", "name" => "Fulfillment", "ofType" => nil },
           "isDeprecated" => false,
           "deprecationReason" => nil },
         { "name" => "node",
           "description" => nil,
           "args" =>
           [{ "name" => "id",
              "description" => nil,
              "type" =>
              { "kind" => "NON_NULL",
                "name" => "Non-Null",
                "ofType" => { "kind" => "SCALAR", "name" => "ID", "ofType" => nil } },
              "defaultValue" => nil }],
           "type" => { "kind" => "INTERFACE", "name" => "Node", "ofType" => nil },
           "isDeprecated" => false,
           "deprecationReason" => nil },
         { "name" => "order",
           "description" => nil,
           "args" =>
           [{ "name" => "id",
              "description" => nil,
              "type" =>
              { "kind" => "NON_NULL",
                "name" => "Non-Null",
                "ofType" => { "kind" => "SCALAR", "name" => "ID", "ofType" => nil } },
              "defaultValue" => nil }],
           "type" => { "kind" => "OBJECT", "name" => "Order", "ofType" => nil },
           "isDeprecated" => false,
           "deprecationReason" => nil },
         { "name" => "product",
           "description" => nil,
           "args" =>
           [{ "name" => "id",
              "description" => nil,
              "type" =>
              { "kind" => "NON_NULL",
                "name" => "Non-Null",
                "ofType" => { "kind" => "SCALAR", "name" => "ID", "ofType" => nil } },
              "defaultValue" => nil }],
           "type" => { "kind" => "OBJECT", "name" => "Product", "ofType" => nil },
           "isDeprecated" => false,
           "deprecationReason" => nil },
         { "name" => "productVariant",
           "description" => nil,
           "args" =>
           [{ "name" => "id",
              "description" => nil,
              "type" =>
              { "kind" => "NON_NULL",
                "name" => "Non-Null",
                "ofType" => { "kind" => "SCALAR", "name" => "ID", "ofType" => nil } },
              "defaultValue" => nil }],
           "type" => { "kind" => "OBJECT", "name" => "ProductVariant", "ofType" => nil },
           "isDeprecated" => false,
           "deprecationReason" => nil },
         { "name" => "refund",
           "description" => nil,
           "args" =>
           [{ "name" => "id",
              "description" => nil,
              "type" =>
              { "kind" => "NON_NULL",
                "name" => "Non-Null",
                "ofType" => { "kind" => "SCALAR", "name" => "ID", "ofType" => nil } },
              "defaultValue" => nil }],
           "type" => { "kind" => "OBJECT", "name" => "Refund", "ofType" => nil },
           "isDeprecated" => false,
           "deprecationReason" => nil },
         { "name" => "shop",
           "description" => nil,
           "args" => [],
           "type" =>
           { "kind" => "NON_NULL",
             "name" => "Non-Null",
             "ofType" => { "kind" => "OBJECT", "name" => "Shop", "ofType" => nil } },
           "isDeprecated" => false,
           "deprecationReason" => nil },
         { "name" => "staffMember",
           "description" => nil,
           "args" =>
           [{ "name" => "id",
              "description" =>
              "The ID of the staff member to return.",
              "type" => { "kind" => "SCALAR", "name" => "ID", "ofType" => nil },
              "defaultValue" => nil }],
           "type" => { "kind" => "OBJECT", "name" => "StaffMember", "ofType" => nil },
           "isDeprecated" => false,
           "deprecationReason" => nil }],
        "inputFields" => nil,
        "interfaces" => [],
        "enumValues" => nil,
        "possibleTypes" => nil }

    type = GraphQL::Client::Type.new('QueryRoot', query_root)
    shop = type.fields['shop']
    assert(shop.object?)
  end
end
