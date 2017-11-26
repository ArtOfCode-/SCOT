class Dispatch::RescueCrew < ApplicationRecord
  has_many :rescue_requests
  belongs_to :status, class_name: 'Dispatch::CrewStatus'
end
