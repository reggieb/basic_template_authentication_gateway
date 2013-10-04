class CallbackController < ApplicationController
  def show

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

  private
  def omniauth
    @omniauth ||= request.env['omniauth.auth']
  end

  def user_hash
    @user_hash ||= (omniauth && omniauth.extra) ? omniauth.extra.raw_info : {}
  end
end
