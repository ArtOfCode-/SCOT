class AddBroadcastItemsFulltextIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :translations, [:content, :final], type: :fulltext
  end
end
