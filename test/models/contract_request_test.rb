require "test_helper"

class ContractRequestTest < ActiveSupport::TestCase
  test "valid fixture" do
    assert contract_requests(:pending_request).valid?
  end

  test "country_name resolves the ISO code" do
    assert_equal "Czechia", contract_requests(:pending_request).country_name
  end

  test "requires a two-letter country code" do
    cr = contract_requests(:pending_request)
    cr.country_code = "CZE"
    assert_not cr.valid?
  end
end
