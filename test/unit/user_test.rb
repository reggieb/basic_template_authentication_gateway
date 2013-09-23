require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:one)
  end

  def test_full_name
    assert_equal("#{@user.first_name} #{@user.last_name}", @user.full_name)
  end

  def test_full_name_with_one_name
    @user.last_name = ""
    assert_equal(@user.first_name, @user.full_name)
  end

end
