class UsersController < ApplicationController
  
  before_filter :get_user, only: [:show, :edit, :update, :delete]

  def index
    @users = User.all
  end

  def show

  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "User created"
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def edit

  end

  def update

  end

  def delete

  end

  private
  def get_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
