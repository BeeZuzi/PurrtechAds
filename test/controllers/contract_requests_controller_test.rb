require "test_helper"

class ContractRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @server = servers(:approved_server)
    sign_in_as(users(:owner))
  end

  def params(extra = {})
    { contract_request: {
      entity_type: "individual", legal_name: "Jane Doe", country_code: "CZ", registered_address: "Prague",
      contact_email: "jane@example.com", preferred_currency: "EUR", payout_method: "bank_transfer"
    }.merge(extra) }
  end

  test "the form shows the terms checkbox and the payout summary" do
    get new_server_contract_request_url(@server)

    assert_response :success
    assert_select "input[type=checkbox][name='contract_request[partner_terms]'][required]"
    assert_select "a[href='#{partner_terms_path}']"
  end

  test "partner terms must be accepted" do
    assert_no_difference "ContractRequest.count" do
      post server_contract_request_url(@server), params: params
    end
    assert_response :unprocessable_entity
  end

  test "accepting the partner terms stores when, which version and from where" do
    assert_difference "ContractRequest.count", 1 do
      post server_contract_request_url(@server), params: params(partner_terms: "1")
    end

    contract = ContractRequest.order(:id).last
    assert contract.partner_terms_accepted?
    assert_equal ContractRequest::PARTNER_TERMS_VERSION, contract.terms_version
    assert contract.terms_accepted_ip.present?
  end

  test "the partner terms page shows the live payout numbers" do
    get partner_terms_url
    assert_response :success
    assert_match Payout.format_cents(PayoutPolicy.reward_cents, PayoutPolicy.currency), response.body
  end
end
