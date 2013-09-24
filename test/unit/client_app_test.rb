require 'test_helper'

class ClientAppTest < ActiveSupport::TestCase

  def test_client_secret
    assert_match secret_pattern, new_client_app.client_secret
  end

  def test_secret_generator
    one = ClientApp.secret_generator
    two = ClientApp.secret_generator
    assert_not_equal one.to_s, two.to_s
    assert_match secret_pattern, one
    assert_match secret_pattern, two
  end

  def test_client_id
    assert_match /warwickshire\.gov\.uk$/, new_client_app.client_id
    assert_match /^[A-F\d]{12,}\./, new_client_app.client_id
  end

  private
  def owner
    @owner ||= users(:one)
  end

  def secret_pattern
    /^[\d\-a-z]{30,}$/
  end

  def new_client_app
    @new_client_app ||= ClientApp.create
  end

end
