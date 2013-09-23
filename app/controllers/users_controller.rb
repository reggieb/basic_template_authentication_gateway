class UsersController < ApplicationController
  
  before_filter :get_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show

  end

  def new
    @user = User.new
  end

  def create
    @user = User.new
    update_user "User created"
  end

  def edit
    render :new
  end

  def update
    remove_empty_password_params
    update_user "User updated"
  end

  def destroy
    @user.destroy
    flash[:notice] = 'User deleted'
    redirect_to users_path
  end

  private
  def get_user
    @user = User.find(params[:id])
  end

  def update_user(message)
    @user.attributes = user_params
    if @user.save
      flash[:notice] = message
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def user_params
    @user_params ||= params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :password,
      :password_confirmation
    )
  end

  def remove_empty_password_params
    user_params.delete_if{|key, value| (/password/ =~ key.to_s) && value.blank?}
  end
end
