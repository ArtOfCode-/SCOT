class Dispatch::RequestStatus < ApplicationRecord
  has_many :requests, class_name: 'Dispatch::Request', foreign_key: 'status_id'

  validates :name, uniqueness: true
end
