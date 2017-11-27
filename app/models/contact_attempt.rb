class ContactAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :rescue_request

  alias request rescue_request
end
