class Broadcast::Item < ApplicationRecord
  belongs_to :municipality, class_name: 'Broadcast::Municipality', optional: true, foreign_key: 'broadcast_municipality_id'

  after_create do
    unless originated_at.present?
      update(originated_at: created_at)
    end
  end
end
