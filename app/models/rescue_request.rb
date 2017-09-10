class RescueRequest < ApplicationRecord
  belongs_to :disaster

  after_create do
    incident_id = (disaster.rescue_requests.maximum(:incident_number) || 0) + 1
    update(incident_number: incident_id)
  end
end
