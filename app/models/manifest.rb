# stores state within antechamber, through the authentication process.
class Manifest < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  HOURS_TO_LIVE = 6

  before_create :creation_tasks

  belongs_to :client_app

  has_one :person

  def timeout_in
    (expires_at.to_i - Time.now.to_i)
  end

  private
  def creation_tasks
    set_code
    set_access_token
    set_refresh_token
    set_expires_at
  end

  def set_access_token
    self.access_token = ClientApp.secret_generator
  end

  def set_refresh_token
    self.refresh_token = ClientApp.secret_generator
  end

  def set_code
    self.code = ClientApp.secret_generator
  end

  def set_expires_at
    self.expires_at = Time.now + HOURS_TO_LIVE.hours
  end

end
