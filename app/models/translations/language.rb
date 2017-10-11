class Translations::Language < ApplicationRecord
  has_many :source_translations, class_name: 'Translation', foreign_key: 'source_lang_id'
  has_many :target_translations, class_name: 'Translation', foreign_key: 'target_lang_id'
end
