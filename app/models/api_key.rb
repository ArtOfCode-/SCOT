class APIKey < ApplicationRecord
  has_many :api_tokens
  has_many :users, through: :api_tokens
  belongs_to :user

  validates :key, uniqueness: true, presence: true
end
