class AddDuplicateOfIdToTranslations < ActiveRecord::Migration[5.1]
  def change
    add_column :translations, :duplicate_of_id, :bigint
    add_foreign_key :translations, :translations, column: :duplicate_of_id
  end
end
