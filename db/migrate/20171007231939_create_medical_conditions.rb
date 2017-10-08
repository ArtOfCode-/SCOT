class CreateMedicalConditions < ActiveRecord::Migration[5.1]
  def change
    create_table :medical_conditions do |t|
      t.string :name
      t.integer :severity
      t.text :description

      t.timestamps
    end
  end
end
