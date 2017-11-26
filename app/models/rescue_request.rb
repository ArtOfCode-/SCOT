class RescueRequest < ApplicationRecord
  belongs_to :disaster
  belongs_to :request_status, optional: true
  belongs_to :medical_status, optional: true
  belongs_to :request_priority, optional: true
  belongs_to :assignee, class_name: 'User', optional: true
  has_many :case_notes
  has_many :contact_attempts
  has_many :dedupe_reviews
  has_many :spam_reviews
  has_many :suggested_edits, as: :resource
  has_and_belongs_to_many :medical_conditions

  after_create do
    incident_id = (disaster.rescue_requests.maximum(:incident_number) || 0) + 1
    status = RequestStatus.where(name: 'New').first
    update(incident_number: incident_id, request_status: status)
  end

  has_many :resource_uses, class_name: 'Dispatch::ResourceUse', foreign_key: 'request_id'
  has_many :resources, through: :resource_uses, class_name: 'Dispatch::Resource'
  belongs_to :rescue_crew, class_name: 'Dispatch::RescueCrew', optional: true
end
