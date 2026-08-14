require "test_helper"

class Api::Plugin::ServersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @server = servers(:approved_server)
  end

  test "rejects requests without credentials" do
    get api_plugin_server_url(@server)
    assert_response :unauthorized
  end

  test "rejects a wrong secret" do
    get api_plugin_server_url(@server), headers: auth_headers(@server).merge("X-Api-Secret" => "wrong")
    assert_response :unauthorized
  end

  test "rejects credentials for a non-approved server" do
    pending_server = servers(:pending_server)
    get api_plugin_server_url(pending_server), headers: auth_headers(pending_server)
    assert_response :unauthorized
  end

  test "returns server info for valid credentials" do
    get api_plugin_server_url(@server), headers: auth_headers(@server)
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal @server.id, body["id"]
    assert_equal @server.name, body["name"]
  end

  test "plugin_config returns the same payload as show" do
    get config_api_plugin_server_url(@server), headers: auth_headers(@server)
    assert_response :success
  end

  test "cannot fetch a different server's info with valid credentials for another server" do
    other = Server.create!(user: users(:owner), name: "Other Realm", description: "x", status: "approved")
    get api_plugin_server_url(other), headers: auth_headers(@server)
    assert_response :not_found
  end

  private

  def auth_headers(server)
    { "X-Api-Key" => server.api_key, "X-Api-Secret" => server.api_secret }
  end
end
