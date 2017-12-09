class RequestPriority < ApplicationRecord
  has_many :rescue_requests

  validates :name, uniqueness: true

  def self.[](key)
    find_by name: key
  end

  def color_class
    %w[danger warning success][index]
  end
end
