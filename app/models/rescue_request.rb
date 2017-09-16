class RescueRequest < ApplicationRecord
  belongs_to :disaster
  belongs_to :request_status, optional: true
  belongs_to :medical_status, optional: true
  belongs_to :request_priority, optional: true
  has_many :case_notes

  after_create do
    incident_id = (disaster.rescue_requests.maximum(:incident_number) || 0) + 1
    status = RequestStatus.where(name: 'New').first
    update(incident_number: incident_id, request_status: status)
  end
end
