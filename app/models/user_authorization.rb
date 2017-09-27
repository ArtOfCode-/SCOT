class UserAuthorization < ApplicationRecord
  belongs_to :user
  belongs_to :resource, polymorphic: true
  belongs_to :granted_by, class_name: 'User'
end
