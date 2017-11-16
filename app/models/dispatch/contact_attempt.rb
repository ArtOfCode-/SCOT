class Dispatch::ContactAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :request, class_name: 'Dispatch::Request'
end
