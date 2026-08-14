require "test_helper"

class PayoutTest < ActiveSupport::TestCase
  test "requires a positive amount" do
    payout = Payout.new(server: servers(:approved_server), amount_cents: 0)
    assert_not payout.valid?
  end

  test "format_cents renders dollars and cents" do
    assert_equal "1.23 USD", Payout.format_cents(123)
  end
end
