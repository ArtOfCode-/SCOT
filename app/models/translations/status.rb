class Translations::Status < ApplicationRecord
  has_many :translations, foreign_key: 'status_id'
end
