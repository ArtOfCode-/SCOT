class Dispatch::Resource < ApplicationRecord
  belongs_to :resource_type, class_name: 'Dispatch::ResourceType'
  has_many :resource_uses, class_name: 'Dispatch::ResourceUse', foreign_key: 'resource_id'
  has_many :requests, through: :resource_uses, class_name: 'Dispatch::Request'
end
