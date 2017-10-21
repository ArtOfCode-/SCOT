class AddNotesToBroadcastItems < ActiveRecord::Migration[5.1]
  def change
    add_column :broadcast_items, :notes, :text
  end
end
