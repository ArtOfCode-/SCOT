class RequestStatus < ApplicationRecord
  has_many :rescue_requests

  validates :name, uniqueness: true


  def self.[](key)
      RequestStatus.find_by name: key
  end
end
