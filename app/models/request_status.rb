class RequestStatus < ApplicationRecord
  has_many :rescue_requests

  validates :name, uniqueness: true
end
