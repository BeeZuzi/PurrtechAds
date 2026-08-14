require "test_helper"

class Admin::FraudFlagsControllerTest < ActionDispatch::IntegrationTest
  test "admin can view fraud flags" do
    sign_in_as(users(:admin))
    get admin_fraud_flags_url
    assert_response :success
  end

  test "superadmin can view fraud flags too" do
    sign_in_as(users(:superadmin))
    get admin_fraud_flags_url
    assert_response :success
  end

  test "a regular user is redirected away" do
    sign_in_as(users(:player))
    get admin_fraud_flags_url
    assert_redirected_to root_url
  end

  test "admin can update a flag's status" do
    sign_in_as(users(:admin))
    flag = FraudFlag.create!(user: users(:player), reason: "shared_ip_multi_account")

    patch admin_fraud_flag_url(flag), params: { fraud_flag: { status: "confirmed" } }

    assert_redirected_to admin_fraud_flag_url(flag)
    assert flag.reload.confirmed?
  end
end
