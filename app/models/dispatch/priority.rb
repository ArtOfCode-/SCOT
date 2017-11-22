class Dispatch::Priority < ApplicationRecord
  has_many :requests, class_name: 'Dispatch::Request', foreign_key: 'priority_id'

  validates :name, uniqueness: true

  def self.[](key)
    find_by name: key
  end

  def color_class
    %w[danger warning success][index]
  end
end
