class Dispatch::CrewStatus < ApplicationRecord
  has_many :crews, class_name: 'Dispatch::RescueCrew', foreign_key: 'status_id'

  validates :name, uniqueness: true

  def self.[](key)
    find_by name: key
  end
end
