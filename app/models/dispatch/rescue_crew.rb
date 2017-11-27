class Dispatch::RescueCrew < ApplicationRecord
  has_many :rescue_requests
  belongs_to :status, class_name: 'Dispatch::CrewStatus'

  def self.dispatch_menu
    limit(100).map { |c| ["#{c.callsign} (#{c.medical? ? 'medical, ' : ''}capacity #{c.capacity})", c.id] }
  end
end
