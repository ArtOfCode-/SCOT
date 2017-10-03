class Broadcast::Item < ApplicationRecord
  belongs_to :municipality, class_name: 'Broadcast::Municipality', optional: true, foreign_key: 'broadcast_municipality_id'
end
