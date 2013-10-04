class AuthorizeController < ApplicationController

  def request_from_client_app
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

  def response_from_authority

     # If the client_id is passed into state like this:
     #   http://localhost:3000/auth/google_oauth2?state=<client_id>
     # the client id is returned when the user returns from google.
     # The state is created by the client app, and this is used
     # to trace the transaction through from the start.
    manifest = Manifest.find_by_state(params[:state])
    client_app = manifest.client_app
    Person.create(
      email: user_hash['email'],
      first_name: user_hash['given_name'],
      last_name: user_hash['family_name'],
      manifest: manifest
    )

    if client_app
      flash[:notice] = "state was #{params[:state]}"
      redirect_to "#{client_app.return_url}?code=#{manifest.code}&response_type=code&state=#{params[:state]}"
    end

  end


  def callback_from_client_app
    unless @client_app = ClientApp.authenticate(
                          id: params[:client_id],
                          secret: params[:client_secret]
                        )
      render json: {error: "Could not find application"}
      return
    end

    unless manifest = get_manifest_by_code_or_grant_type
      render json: {error: "Could not authenticate access code"}
      return
    end

    render json: {
      access_token: manifest.access_token,
      refresh_token: manifest.refresh_token,
      expires_in: manifest.timeout_in
    }
  end

  def user_lookup_by_client_app
    manifest = Manifest.find_by_access_token(params[:oauth_token])
    person = manifest.person
    hash = {
      provider: 'antechamber',
      id: person.id.to_s,
      email: person.email,
      extra: {
         first_name: person.first_name,
         last_name: person.last_name
      }
    }

    render json: hash.to_json
  end

  private
  def omniauth
    @omniauth ||= request.env['omniauth.auth']
  end

  def user_hash
    @user_hash ||= (omniauth && omniauth.extra) ? omniauth.extra.raw_info : {}
  end

  def get_manifest_by_code_or_grant_type
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
