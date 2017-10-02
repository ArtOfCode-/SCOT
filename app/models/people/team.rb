class People::Team < ApplicationRecord
  has_many :memberships, class_name: 'People::TeamMembership'
  has_many :volunteers, class_name: 'People::Volunteer', through: :memberships
end
