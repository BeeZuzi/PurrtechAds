require "test_helper"

class ServersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:owner)) }

  test "the setup page says the plugin is coming soon until there is a download" do
    get new_server_url

    assert_response :success
    assert_select "span[aria-disabled=true]", text: /coming soon/
    assert_select "a", text: "Download plugin", count: 0
  end

  test "the setup page links the plugin once a download URL is set" do
    ENV["PLUGIN_DOWNLOAD_URL"] = "https://example.com/ads-plugin.jar"

    get new_server_url

    assert_select "a[href='https://example.com/ads-plugin.jar']", text: "Download plugin"
    assert_select "span[aria-disabled=true]", count: 0
  ensure
    ENV.delete("PLUGIN_DOWNLOAD_URL")
  end
end
