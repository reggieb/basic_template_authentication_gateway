require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:one)
  end

  def test_index
    get :index
    assert_response :success
    assert_equal User.all, assigns('users')
  end

  def test_show
    get :show, id: @user.id
    assert_response :success
    assert_equal @user, assigns('user')
  end

  def test_new
    get :new
    assert_response :success
  end

  def test_create
    post :create, user: {
      first_name: 'Mark',
      last_name: 'Someone',
      email: 'mark@example.com',

    }
  end

end
