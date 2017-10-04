class DedupeReview < ApplicationRecord
  belongs_to :rescue_request
  belongs_to :user
  belongs_to :dupe_of, class_name: "RescueRequest", optional: true
end
