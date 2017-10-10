class MedicalCondition < ApplicationRecord
  has_many :medical_conditions_rescue_requests
  has_many :rescue_requests, through: :medical_conditions_rescue_requests
end
