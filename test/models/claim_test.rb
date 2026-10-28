require "test_helper"

class ClaimTest < ActiveSupport::TestCase
  test "generates a unique token and a 24h expiry on create" do
    claim = Claim.create!(user: users(:player), server: servers(:approved_server))
    assert claim.token.present?
    assert_in_delta 24.hours.from_now, claim.expires_at, 5.seconds
  end

  test "claimable? is true only while pending and unexpired" do
    claim = Claim.create!(user: users(:player), server: servers(:approved_server))
    assert claim.claimable?

    claim.update!(status: "redeemed")
    assert_not claim.claimable?
  end

  test "claimable? and expired? once the expiry has passed" do
    claim = Claim.create!(user: users(:player), server: servers(:approved_server), expires_at: 1.minute.ago)
    assert_not claim.claimable?
    assert claim.expired?
  end

  test "defaults to simulated source" do
    claim = Claim.create!(user: users(:player), server: servers(:approved_server))
    assert claim.source_simulated?
  end

  test "external_id must be unique when present" do
    Claim.create!(user: users(:player), server: servers(:approved_server), external_id: "adgate-123")
    dupe = Claim.new(user: users(:owner), server: servers(:approved_server), external_id: "adgate-123")
    assert_not dupe.valid?
  end

  test "multiple claims may have a blank external_id" do
    Claim.create!(user: users(:player), server: servers(:approved_server))
    second = Claim.new(user: users(:owner), server: servers(:approved_server))
    assert second.valid?
  end
end
