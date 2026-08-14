require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "logs in with correct credentials" do
    post session_url, params: { email: users(:player).email, password: "password123" }
    assert_redirected_to dashboard_url
  end

  test "rejects a wrong password" do
    post session_url, params: { email: users(:player).email, password: "wrongpassword" }
    assert_response :unprocessable_entity
  end

  test "a banned user is redirected to the banned page instead of signed in" do
    user = users(:player)
    user.update!(banned_at: Time.current)

    post session_url, params: { email: user.email, password: "password123" }

    assert_redirected_to banned_url(user_id: user.id)
  end

  test "an expired timed ban does not block login" do
    user = users(:player)
    user.update!(banned_at: 2.days.ago, banned_until: 1.day.ago)

    post session_url, params: { email: user.email, password: "password123" }

    assert_redirected_to dashboard_url
  end
end
