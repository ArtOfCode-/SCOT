class Dispatch::CaseNote < ApplicationRecord
  belongs_to :request, class_name: 'Dispatch::Request'
  belongs_to :author, class_name: 'User'
end
