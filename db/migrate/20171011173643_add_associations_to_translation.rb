class AddAssociationsToTranslation < ActiveRecord::Migration[5.1]
  def change
    add_column :translations, :status_id, :integer
    add_column :translations, :priority_id, :integer
  end
end
