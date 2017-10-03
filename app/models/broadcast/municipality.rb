class Broadcast::Municipality < ApplicationRecord
  has_many :items, class_name: 'Broadcast::Item', foreign_key: 'broadcast_municipality_id'

  validates :name, uniqueness: true
end
