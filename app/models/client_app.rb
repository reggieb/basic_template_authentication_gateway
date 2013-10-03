class ClientApp < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  before_create :creation_tasks

  belongs_to :owner, :class_name => 'User'

  has_many :manifests

  validates :return_url, presence: true

  def self.secret_generator
    SecureRandom.uuid
  end

  def self.app_domain
    'warwickshire.gov.uk'
  end

  def self.authenticate(args)
    find_by_client_id_and_client_secret(args[:id], args[:secret])
  end

  private
  def creation_tasks
    set_client_secret
    set_client_id
  end

  def set_client_secret
    self.client_secret = self.class.secret_generator
  end

  def set_client_id
    self.client_id = [hex_time_now, self.class.app_domain].join('.')
  end

  def hex_time_now
    sprintf("%02X", time_string)
  end

  def time_string
    Time.now.strftime("%y%W%w%H%M%S%6N")
  end
end

