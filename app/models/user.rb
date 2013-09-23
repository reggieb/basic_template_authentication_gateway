class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable,
  # :registerable, :recoverable, :rememberable,
  devise :database_authenticatable,  :trackable, :validatable

  include ActiveModel::ForbiddenAttributesProtection

  def full_name
    [first_name, last_name].select(&:present?).join(' ')
  end

end
