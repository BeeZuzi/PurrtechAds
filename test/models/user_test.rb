require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(email: "new@example.com", minecraft_nick: "NewPlayer",
                     password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "requires unique email case-insensitively" do
    dupe = User.new(email: users(:player).email.upcase, minecraft_nick: "Another",
                     password: "password123", password_confirmation: "password123")
    assert_not dupe.valid?
    assert_includes dupe.errors[:email], "has already been taken"
  end

  test "requires unique minecraft_nick case-insensitively" do
    dupe = User.new(email: "other@example.com", minecraft_nick: users(:player).minecraft_nick.upcase,
                     password: "password123", password_confirmation: "password123")
    assert_not dupe.valid?
  end

  test "rejects an invalid minecraft_uuid format" do
    user = users(:player)
    user.minecraft_uuid = "not-a-uuid"
    assert_not user.valid?
  end

  test "banned? is false without banned_at" do
    assert_not users(:player).banned?
  end

  test "banned? respects banned_until expiry" do
    user = users(:player)
    user.banned_at = 1.day.ago
    user.banned_until = 1.hour.ago
    assert_not user.banned?

    user.banned_until = 1.hour.from_now
    assert user.banned?
  end

  test "confirmed? reflects confirmed_at" do
    user = users(:player)
    assert user.confirmed?

    user.confirmed_at = nil
    assert_not user.confirmed?
  end

  test "password_reset token is invalidated after the password changes" do
    user = users(:player)
    token = user.generate_token_for(:password_reset)

    user.update!(password: "differentpassword1", password_confirmation: "differentpassword1")

    assert_nil User.find_by_token_for(:password_reset, token)
  end

  test "email_confirmation token roundtrips and confirm! sets confirmed_at" do
    user = users(:player)
    user.update!(confirmed_at: nil)
    token = user.generate_token_for(:email_confirmation)

    found = User.find_by_token_for(:email_confirmation, token)
    assert_equal user, found

    found.confirm!
    assert user.reload.confirmed?
  end
end
