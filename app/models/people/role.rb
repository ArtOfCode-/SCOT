class People::Role < ApplicationRecord
  has_and_belongs_to_many :volunteers, class_name: 'People::Volunteer'
end
