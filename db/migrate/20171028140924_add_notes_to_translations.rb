class AddNotesToTranslations < ActiveRecord::Migration[5.1]
  def change
    add_column :translations, :notes, :text
  end
end
