require 'test_helper'

class AuthorizeControllerTest < ActionController::TestCase
  def setup
    @client_app = client_apps(:example)
  end

  def test_identify_client_app
    assert_difference 'Manifest.count' do
      get :request_from_client_app, client_id: @client_app.client_id
    end
    assert_response :redirect
  end

  def test_identity_client_app_with_unknown_id
    assert_no_difference 'Manifest.count' do
      get :request_from_client_app, client_id: SecureRandom.uuid
    end
    assert_unauthorized_error
  end

  def test_response_from_authority
    create_manifest(state: SecureRandom.uuid)

    @request.env['omniauth.auth'] = person_data

    assert_difference 'Person.count' do
      get(
        :response_from_authority,
        {
          state: @manifest.state,
          id: 'antechamber'
        }
      )
    end
    assert_response :redirect
    assert_equal(@email, Person.last.email)
  end

#  From: https://developers.google.com/accounts/docs/OAuth2UserAgent#handlingtheresponse
#    An example error response is shown below:
#    https://oauth2-login-demo.appspot.com/oauthcallback#error=access_denied
  def test_response_from_authority_with_error
    assert_no_difference 'Person.count' do
      get(
        :response_from_authority,
        id: 'antechamber',
        error: 'access_denied'
      )
    end
    assert_unauthorized_error
  end

  def test_callback_from_client_app
    create_manifest(state: SecureRandom.uuid)
    post(
      :callback_from_client_app,
      client_id: @client_app.client_id,
      client_secret: @client_app.client_secret,
      code: @manifest.code
    )
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @manifest.access_token, json['access_token']
    assert_equal @manifest.timeout_in, json['expires_in']
  end

  def test_callback_from_client_app_with_wrong_secret
    create_manifest(state: SecureRandom.uuid)
    post(
      :callback_from_client_app,
      client_id: @client_app.client_id,
      client_secret: SecureRandom.uuid,
      code: @manifest.code
    )
    assert_unauthorized_error
  end

  def test_callback_from_client_app_with_wrong_client_id
    create_manifest(state: SecureRandom.uuid)
    post(
      :callback_from_client_app,
      client_id: SecureRandom.uuid,
      client_secret: @client_app.client_secret,
      code: @manifest.code
    )
    assert_unauthorized_error
  end

  def test_callback_from_client_app_with_wrong_code
    create_manifest(state: SecureRandom.uuid)
    post(
      :callback_from_client_app,
      client_id: @client_app.client_id,
      client_secret: @client_app.client_secret,
      code: SecureRandom.uuid
    )
    assert_unauthorized_error
  end

  def test_callback_from_client_app_with_grant_type
    create_manifest(state: SecureRandom.uuid)
    post(
      :callback_from_client_app,
      client_id: @client_app.client_id,
      client_secret: @client_app.client_secret,
      grant_type: 'refresh_token',
      refresh_token: @manifest.refresh_token
    )
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @manifest.access_token, json['access_token']
    assert_equal @manifest.timeout_in, json['expires_in']
  end

  def test_callback_from_client_app_with_grant_type_error
    create_manifest(state: SecureRandom.uuid)
    post(
      :callback_from_client_app,
      client_id: @client_app.client_id,
      client_secret: @client_app.client_secret,
      grant_type: 'refresh_token',
      refresh_token: SecureRandom.uuid
    )
    assert_unauthorized_error
  end

  def test_identity_lookup_by_client_app
    test_response_from_authority
    get(
      :identity_lookup_by_client_app,
      oauth_token: @manifest.access_token
    )
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal Person.last.email, json['email']
  end

  def test_identity_lookup_by_client_app_with_invalid_token
    test_response_from_authority
    get(
      :identity_lookup_by_client_app,
      oauth_token: SecureRandom.uuid
    )
    assert_unauthorized_error
  end

  private
  def assert_unauthorized_error
    assert_response :unauthorized
    assert response.body['error'], "Response body should have error message"
  end

  def create_manifest(args = {})
    attributes = args.merge(
      client_app: @client_app,
      redirect_uri: @client_app.return_uri
    )
    @manifest = Manifest.create(attributes)
  end

  def person_data
    @email = 'someone@example.com'
    Hashie::Mash.new(
      'extra' => {
        'raw_info' => {
          'email' => @email,
          'given_name' => 'Some',
          'family_name' => 'One'
        }
      }
    )
  end

end
