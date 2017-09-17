class CreateMedicalStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :medical_statuses do |t|
      t.string :name
      t.string :description
      t.string :created_at
      t.string :updated_at
    end
  end
end
