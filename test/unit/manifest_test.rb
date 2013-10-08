require 'test_helper'

class ManifestTest < ActiveSupport::TestCase

  def setup
    @client_app = ClientApp.create(return_uri: 'https://example.com')
    @manifest = @client_app.manifests.create
  end

  def test_code
    assert_match secret_pattern, @manifest.code
  end

  def test_access_token
    assert_match secret_pattern, @manifest.access_token
  end

  def test_refresh_token
    assert_match secret_pattern, @manifest.refresh_token
  end

  def test_expires_at
    time_string = "%H %d-%m-%Y"
    same_hour = @manifest.created_at + Manifest::HOURS_TO_LIVE.hours
    assert_equal same_hour.strftime(time_string), @manifest.expires_at.strftime(time_string)
  end

  def test_timeout_in
    assert_equal (@manifest.expires_at.to_i - Time.now.to_i), @manifest.timeout_in
  end

end

