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

  def test_authenticate
    result =  ClientApp.authenticate(
                id: new_client_app.client_id,
                secret: new_client_app.client_secret
              )
    assert_equal new_client_app, result
  end

  def test_failure_to_authenticate
    tests = {
      'one' => ClientApp.secret_generator,
      ClientApp.secret_generator => 'one',
      ClientApp.secret_generator => ClientApp.secret_generator,
      ClientApp.secret_generator => nil,
      nil => ClientApp.secret_generator,
      'two' => nil
    }
    tests.each do |client_id, client_secret|
      assert_equal nil, ClientApp.authenticate(id: client_id, secret: client_secret)
    end
  end

  private
  def owner
    @owner ||= users(:one)
  end

  def new_client_app
    @return_url = 'https:/example.com'
    @new_client_app ||= ClientApp.create(return_url: @return_url)
  end

end
