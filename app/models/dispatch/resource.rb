class Dispatch::Resource < ApplicationRecord
  belongs_to :resource_type, class_name: 'Dispatch::ResourceType'
  has_many :resource_uses, class_name: 'Dispatch::ResourceUse', foreign_key: 'resource_id'
  has_many :rescue_requests, through: :resource_uses

  def self.dispatch_menu
    limit(100).includes(:resource_type).map { |r| ["#{r.name} (#{r.resource_type.name})", r.id] }
  end
end
