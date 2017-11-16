class Dispatch::RescueCrew < ApplicationRecord
  has_many :requests, class_name: 'Dispatch::Request', foreign_key: 'rescue_crew_id'
  belongs_to :status, class_name: 'Dispatch::CrewStatus'
end
