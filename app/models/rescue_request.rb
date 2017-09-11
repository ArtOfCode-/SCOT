class RescueRequest < ApplicationRecord
  belongs_to :disaster
  has_many :review_tasks
end
