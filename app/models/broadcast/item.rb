class Broadcast::Item < ApplicationRecord
  belongs_to :municipality, class_name: 'Broadcast::Municipality', optional: true, foreign_key: 'broadcast_municipality_id'
  belongs_to :user, optional: true

  scope :active, -> { where(deprecated: false) }

  after_create do
    update(originated_at: created_at) unless originated_at.present?
  end
end
