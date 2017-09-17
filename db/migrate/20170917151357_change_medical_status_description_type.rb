class ChangeMedicalStatusDescriptionType < ActiveRecord::Migration[5.1]
  def change
    change_column :medical_statuses, :description, :text
  end
end
