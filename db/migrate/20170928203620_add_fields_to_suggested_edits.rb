class AddFieldsToSuggestedEdits < ActiveRecord::Migration[5.1]
  def change
    add_column :suggested_edits, :old_values, :text
    add_column :suggested_edits, :reviewed_at, :datetime
  end
end
