class People::Volunteer < ApplicationRecord
  has_many :team_memberships, class_name: 'People::TeamMembership'
  has_many :teams, class_name: 'People::Team', through: :team_memberships
  has_and_belongs_to_many :roles, class_name: 'People::Role'
end
