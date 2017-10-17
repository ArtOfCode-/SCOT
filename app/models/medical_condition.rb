class MedicalCondition < ApplicationRecord
  has_and_belongs_to_many :rescue_requests
end
