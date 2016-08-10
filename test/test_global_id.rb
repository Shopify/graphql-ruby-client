require_relative 'test_helper'
require 'minitest/autorun'

module GraphQL
  module Client
    class TestGlobalID < Minitest::Test
      def test_global_id
        gid = GlobalID.new('gid://shopify/Product/80')

        assert_equal('shopify', gid.domain)
        assert_equal('Product', gid.model_name)
      end
    end
  end
end
