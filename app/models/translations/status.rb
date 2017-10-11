class Translations::Status < ApplicationRecord
  has_many :translations, foreign_key: 'status_id'

  validates :name, uniqueness: true

  def self.[](key)
    find_by name: key
  end
end
