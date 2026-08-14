require "test_helper"

class FraudDetectorTest < ActiveSupport::TestCase
  test "flags the third distinct account claiming from the same IP within the window" do
    server = servers(:approved_server)
    ip = "9.9.9.9"

    [ users(:player), users(:owner) ].each do |user|
      claim = server.claims.create!(user: user, ip_address: ip)
      FraudDetector.new(claim).call
    end
    assert_equal 0, FraudFlag.count

    third_user = User.create!(email: "third@example.com", minecraft_nick: "ThirdUser",
                               password: "password123", password_confirmation: "password123")
    claim = server.claims.create!(user: third_user, ip_address: ip)
    FraudDetector.new(claim).call

    assert_equal 1, FraudFlag.count
    assert_equal "shared_ip_multi_account", FraudFlag.last.reason
  end

  test "does not flag distinct IPs" do
    server = servers(:approved_server)

    claim1 = server.claims.create!(user: users(:player), ip_address: "1.1.1.1")
    FraudDetector.new(claim1).call
    claim2 = server.claims.create!(user: users(:owner), ip_address: "2.2.2.2")
    FraudDetector.new(claim2).call

    assert_equal 0, FraudFlag.count
  end
end
