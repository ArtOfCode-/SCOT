class Disaster < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false).or(where(active: nil)) }
end
