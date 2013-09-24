require 'test_helper'

class ClientAppsControllerTest < ActionController::TestCase
  def setup
    @client_app = client_apps(:example)
    sign_in @client_app.owner
  end

  def test_index
    get :index
    assert_response :success
    assert_equal ClientApp.all, assigns('client_apps')
  end

  def test_show
    get :show, id: @client_app
    assert_response :success
    assert_equal @client_app, assigns('client_app')
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    name = 'new_app'
    assert_difference 'ClientApp.count' do
      post :create, client_app: {
        name: name,
        return_url: 'http://example.com/new/place'
      }
    end
    client_app = ClientApp.last
    assert_equal(name, client_app.name)
    # Make sure client id and secret are generated. Leave testing of format to unit test
    assert_match(/\w+/, client_app.client_id)
    assert_match(/\w+/, client_app.client_secret)
  end

  def test_owner
    test_create
    assert_equal(@client_app.owner, ClientApp.last.owner)
  end

  def test_edit
    get :edit, id: @client_app
    assert_response :success
    assert_equal @client_app, assigns('client_app')
  end

  def test_update
    name = 'new_name'
    assert_no_difference 'ClientApp.count' do
      put :update, id: @client_app, client_app: {name: name}
      assert_equal name, @client_app.reload.name
    end

  end

  def test_destroy
    assert_difference 'ClientApp.count', -1 do
      delete :destroy, id: @client_app
    end
  end
end
