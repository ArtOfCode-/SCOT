class Dispatch::RequestStatus < ApplicationRecord
  has_many :requests, class_name: 'Dispatch::Request', foreign_key: 'status_id'

  validates :name, uniqueness: true

  def self.[](key)
    find_by name: key
  end

  def marker_type
    %w[danger warning success info][index]
  end

  def icon
    %w[exclamation-triangle exclamation-circle check info-circle][index]
  end
end
