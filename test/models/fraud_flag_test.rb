require "test_helper"

class FraudFlagTest < ActiveSupport::TestCase
  test "requires a known reason" do
    flag = FraudFlag.new(user: users(:player), reason: "not_a_real_reason")
    assert_not flag.valid?
  end

  test "defaults to pending status" do
    flag = FraudFlag.create!(user: users(:player), reason: "shared_ip_multi_account")
    assert flag.pending?
  end
end
