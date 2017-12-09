class Dispatch::Resource < ApplicationRecord
  belongs_to :resource_type, class_name: 'Dispatch::ResourceType'
  has_many :resource_uses, class_name: 'Dispatch::ResourceUse', foreign_key: 'resource_id'
  has_many :requests, through: :resource_uses, class_name: 'RescueRequest'

  def self.dispatch_menu(request)
    limit(50).includes(:resource_type).where.not(resource_type: Dispatch::ResourceType['Rest Stop'])
             .order("SQRT(POW(`long` - #{request.long}, 2) + POW(`lat` - #{request.lat}, 2))")
             .map { |r| ["#{r.name} (#{r.resource_type.name})", r.id] }
  end

  def self.rest_stops
    limit(50).includes(:resource_type).where(resource_type: Dispatch::ResourceType['Rest Stop'])
             .order("SQRT(POW(`long` - #{request.long}, 2) + POW(`lat` - #{request.lat}, 2))")
             .map { |r| ["#{r.name} (#{r.resource_type.name})", r.id] }
  end
end
