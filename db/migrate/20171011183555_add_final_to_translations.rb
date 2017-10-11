class AddFinalToTranslations < ActiveRecord::Migration[5.1]
  def change
    add_column :translations, :final, :text
  end
end
