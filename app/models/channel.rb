class Channel < ApplicationRecord
  has_and_belongs_to_many :grantable_roles, class_name: 'Role', foreign_key: 'channel_id'

  resourcify
end
