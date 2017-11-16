class Dispatch::Request < ApplicationRecord
  has_and_belongs_to_many :assignees, class_name: 'User', join_table: :dispatch_requests_users
  has_many :case_notes, class_name: 'Dispatch::CaseNote', foreign_key: :request_id
  has_many :contact_attempts, class_name: 'Dispatch::ContactAttempt'
  has_many :resource_uses, class_name: 'Dispatch::ResourceUse', foreign_key: 'request_id'
  has_many :resources, through: :resource_uses, class_name: 'Dispatch::Resource'
  belongs_to :status, class_name: 'Dispatch::RequestStatus'
  belongs_to :priority, class_name: 'Dispatch::Priority'
  belongs_to :rescue_crew, class_name: 'Dispatch::RescueCrew', optional: true
end
