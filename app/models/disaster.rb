class Disaster < ApplicationRecord
  has_many :rescue_requests
  has_many :requests, class_name: 'Dispatch::Request'

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false).or(where(active: nil)) }
end
