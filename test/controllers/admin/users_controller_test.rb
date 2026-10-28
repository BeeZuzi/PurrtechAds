require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "an admin can change a role" do
    sign_in_as(users(:admin))

    patch admin_user_url(users(:player)), params: { user: { role: "approver" } }

    assert_redirected_to admin_user_url(users(:player))
    assert_equal "approver", users(:player).reload.role
  end

  test "an admin can't hand out the superadmin role" do
    sign_in_as(users(:admin))

    patch admin_user_url(users(:player)), params: { user: { role: "superadmin" } }

    assert_redirected_to admin_user_url(users(:player))
    assert flash[:alert].present?
    assert_equal "user", users(:player).reload.role
  end

  test "a superadmin can hand out the superadmin role" do
    sign_in_as(users(:superadmin))

    patch admin_user_url(users(:player)), params: { user: { role: "superadmin" } }

    assert_equal "superadmin", users(:player).reload.role
  end
end
