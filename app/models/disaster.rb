class Disaster < ApplicationRecord
  has_many :rescue_requests

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false).or(where(active: nil)) }
end
