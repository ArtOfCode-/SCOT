class CreateSuggestedEdits < ActiveRecord::Migration[5.1]
  def change
    create_table :suggested_edits do |t|
      t.references :resource, polymorphic: true
      t.references :user, foreign_key: true
      t.string :result
      t.integer :reviewed_by_id
      t.text :new_values
      t.text :comment

      t.timestamps
    end
  end
end
