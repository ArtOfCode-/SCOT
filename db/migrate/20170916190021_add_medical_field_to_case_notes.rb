class AddMedicalFieldToCaseNotes < ActiveRecord::Migration[5.1]
  def change
    add_column :case_notes, :medical, :boolean
  end
end
