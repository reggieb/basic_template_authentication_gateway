class PeopleController < ApplicationController

  def show
    manifest = Manifest.find_by_access_token(params[:oauth_token])
    person = manifest.person
    hash = {
      :provider => 'antechamber',
      :id => person.id.to_s,
      :info => {
         :email      => person.email,
      },
      :extra => {
         :first_name => person.first_name,
         :last_name  => person.last_name
      }
    }

    render :json => hash.to_json
  end
end
