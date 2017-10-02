class People::TeamMembership < ApplicationRecord
  belongs_to :volunteer, class_name: 'People::Volunteer'
  belongs_to :team, class_name: 'People::Team'
end
