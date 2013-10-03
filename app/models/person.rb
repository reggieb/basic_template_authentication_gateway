class Person < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :manifest
end
