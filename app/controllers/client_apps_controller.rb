class ClientAppsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :get_client_app, only: [:show, :edit, :update, :destroy]

  def index
    @client_apps = ClientApp.all
  end

  def show

  end

  def new
    @client_app = ClientApp.new
  end

  def create
    @client_app = ClientApp.new
    update_client_app "Client App created"
  end

  def edit
    render :new
  end

  def update
    update_client_app "Client App updated"
  end

  def destroy
    @client_app.destroy
    flash[:notice] = 'Client App deleted'
    redirect_to client_apps_path
  end

  private
  def get_client_app
    @client_app = ClientApp.find(params[:id])
  end

  def update_client_app(message)
    @client_app.attributes = client_app_params
    @client_app.owner ||= current_user
    if @client_app.save
      flash[:notice] = message
      redirect_to client_app_path(@client_app)
    else
      render :new
    end
  end

  def client_app_params
    @client_app_params ||= params.require(:client_app).permit(
      :return_url,
      :name
    )
  end

end
