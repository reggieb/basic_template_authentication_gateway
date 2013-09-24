class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable,
  # :registerable, :recoverable, :rememberable,
  devise :database_authenticatable,  :trackable, :validatable


  def full_name
    [first_name, last_name].select(&:present?).join(' ')
  end

end
