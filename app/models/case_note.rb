class CaseNote < ApplicationRecord
  belongs_to :rescue_request
  belongs_to :user, optional: true

  alias request rescue_request
end
