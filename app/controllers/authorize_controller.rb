class AuthorizeController < ApplicationController

  def new
    client_app = ClientApp.find_by_client_id(params[:client_id])
    if client_app
      @manifest = client_app.manifests.create(
        redirect_uri: params[:redirect_uri],
        state: params[:state]
      )

      forward_to_trusted_authenticator
    else
      render text: "Whoops."
    end
  end


  def create
    unless @client_app = ClientApp.authenticate(
                          id: params[:client_id],
                          secret: params[:client_secret]
                        )
      render json: {error: "Could not find application"}
      return
    end

    unless manifest = get_manifest
      render json: {error: "Could not authenticate access code"}
      return
    end

    render json: {
      access_token: manifest.access_token,
      refresh_token: manifest.refresh_token,
      expires_in: manifest.timeout_in
    }
  end

  private
  def get_manifest
    if params[:code]
      @client_app.manifests.find_by_code(params[:code])
    else
      grant_type = params[:grant_type]
      @client_app.manifests.send("find_by_#{grant_type}", params[grant_type])
    end
  end


  def forward_to_trusted_authenticator
    redirect_to "/auth/google_oauth2/?state=#{@manifest.state}"
  end


end
