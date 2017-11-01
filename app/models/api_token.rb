class APIToken < ApplicationRecord
  belongs_to :user
  belongs_to :api_key

  validates :token, uniqueness: true, presence: true
  validates :code, uniqueness: true, presence: true

  serialize :scopes
end
