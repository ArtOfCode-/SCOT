class Translations::Priority < ApplicationRecord
  has_many :translations, foreign_key: 'priority_id'

  validates :name, uniqueness: true

  def self.[](key)
    find_by name: key
  end
end
