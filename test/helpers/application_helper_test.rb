require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "plugin_download_url is nil until a download exists" do
    assert_nil plugin_download_url
  end

  test "plugin_download_url comes from PLUGIN_DOWNLOAD_URL" do
    ENV["PLUGIN_DOWNLOAD_URL"] = "https://example.com/ads-plugin.jar"
    assert_equal "https://example.com/ads-plugin.jar", plugin_download_url
  ensure
    ENV.delete("PLUGIN_DOWNLOAD_URL")
  end
end
