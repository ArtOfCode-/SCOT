class Broadcast::Status < ApplicationRecord
  has_many :items, class_name: 'Broadcast::Item', foreign_key: 'status_id'

  def self.[](key)
    find_by name: key
  end
end
