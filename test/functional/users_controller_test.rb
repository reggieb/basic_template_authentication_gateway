require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:one)
    sign_in @user
  end

  def test_index
    get :index
    assert_response :success
    assert_equal User.all, assigns('users')
  end

  def test_show
    get :show, id: @user
    assert_response :success
    assert_equal @user, assigns('user')
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    email = 'mark@example.com'
    assert_difference 'User.count' do
      post :create, user: {
        first_name: 'Mark',
        last_name: 'Someone',
        email: email,
        password: 'thispassword',
        password_confirmation: 'thispassword'
      }
    end
    assert_equal(email, User.last.email)
  end

  def test_edit
    get :edit, id: @user
    assert_response :success
    assert_equal @user, assigns('user')
  end

  def test_update
    email = 'new@example.com'
    assert_no_difference 'User.count' do
      put :update, id: @user, user: {'email' => email}
      assert_equal email, @user.reload.email
    end
    
  end

  def test_destroy
    assert_difference 'User.count', -1 do
      delete :destroy, id: @user
    end
  end

end
