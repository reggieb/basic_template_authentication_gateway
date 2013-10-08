# A proxy server for the authentication of a client application by a trusted authority.
# -------------------------------------------------------------------------------------
#
# The complete process (when the remote authority is google) looks something like this:
#
# [1. client_app: via its instance of oauth gem as oauth client]
#    <--> [2. antechamber: via authorise controller as oauth server]
#      <--> [3. antechamber: via its instance of oauth gem as oauth client]
#        <--> [4. google: as oauth server]
#
# This controller is mainly concerned with what is going on at the second stage.
#
# Note: The breakdown of the process into steps is to help me keep track
# of what needs to be done at the second stage. Therefore, they do not detail
# everything that is going on. There are protocol exchanges
# going on at other stages, that are not reflected in these steps.
class AuthorizeController < ApplicationController

  # First step: the client app initiates the process with a request.
  def request_from_client_app
    
    if identify_client_app
      initialize_manifest
      forward_to_trusted_authority
    else
      render_error "Could not start process to authenticate"
    end

  end

  # Second step: The authority responds with identity information if authenticated
  def response_from_authority

    if identity_returned?
      store_identity_information
      redirect_to "#{@client_app.return_uri}?code=#{@manifest.code}&response_type=code&state=#{params[:state]}"
    else
      render_error "Failed authentication"
    end

  end

  # Third step: Authenticates client app and return tokens
  def callback_from_client_app
    unless authenticate_client_app
      render_error "Could not authenticate application"
      return
    end

    unless manifest_by_code_or_grant_type
      render_error "Could not authenticate access code"
      return
    end

    render json: {
      access_token: @manifest.access_token,
      refresh_token: @manifest.refresh_token,
      expires_in: @manifest.timeout_in
    }
  end

  # Final step :Client app requests identify information
  def identity_lookup_by_client_app

    if get_person_via_manifest
      render json: {
        provider: 'antechamber',
        id: @person.id.to_s,
        email: @person.email,
        extra: {
           first_name: @person.first_name,
           last_name: @person.last_name
        }
      }
    else
      render_error "Failed authentication"
    end
  end

  private

  def identify_client_app
    @client_app = ClientApp.find_by_client_id(params[:client_id])
  end

  def initialize_manifest
      @manifest = @client_app.manifests.create(
        redirect_uri: params[:redirect_uri],
        state: params[:state]
      )
  end

  # Note that the forwarding is not done directly, but instead the requests
  # is passed on to the local instance of oauth.
  def forward_to_trusted_authority
    redirect_to "/auth/google_oauth2/?state=#{@manifest.state}"
  end

  def identity_returned?
    manifest_by_state and manifest_client_app and !user_hash.empty?
  end

  def manifest_by_state
    @manifest = Manifest.find_by_state(params[:state])
  end

  def manifest_client_app
    @client_app = @manifest.client_app
  end

  def store_identity_information

    Person.create(
      email: user_hash['email'],
      first_name: user_hash['given_name'],
      last_name: user_hash['family_name'],
      manifest: @manifest
    )
  end

  def omniauth
    @omniauth ||= request.env['omniauth.auth']
  end

  def user_hash
    @user_hash ||= (omniauth && omniauth.extra) ? omniauth.extra.raw_info : {}
  end

  def authenticate_client_app
    @client_app = ClientApp.authenticate(
                    id: params[:client_id],
                    secret: params[:client_secret]
                  )
  end

  def manifest_by_code_or_grant_type
    @manifest = get_manifest_by_code_or_grant_type
  end

  def get_manifest_by_code_or_grant_type
    if params[:code]
      @client_app.manifests.find_by_code(params[:code])
    else
      grant_type = params[:grant_type]
      @client_app.manifests.send("find_by_#{grant_type}", params[grant_type])
    end
  end

  def get_person_via_manifest
    manifest = Manifest.find_by_access_token(params[:oauth_token])
    @person = manifest.person if manifest
  end

  def render_error(message)
      render  json: {error: message},  status: :unauthorized
  end

end
