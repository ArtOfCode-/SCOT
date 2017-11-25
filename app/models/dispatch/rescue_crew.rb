class Dispatch::RescueCrew < ApplicationRecord
  has_many :requests, class_name: 'Dispatch::Request', foreign_key: 'rescue_crew_id'
  belongs_to :status, class_name: 'Dispatch::CrewStatus'

  def self.dispatch_menu
    limit(100).map { |c| ["#{c.callsign} (#{c.medical? ? 'medical, ' : ''}capacity #{c.capacity})", c.id] }
  end
end
