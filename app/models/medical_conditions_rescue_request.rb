class MedicalConditionsRescueRequest < ApplicationRecord
  belongs_to :rescue_request
  belongs_to :medical_condition
end