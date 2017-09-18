class SpamReview < ApplicationRecord
  belongs_to :rescue_request
  belongs_to :user
end
