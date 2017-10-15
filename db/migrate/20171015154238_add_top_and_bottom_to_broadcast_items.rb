class AddTopAndBottomToBroadcastItems < ActiveRecord::Migration[5.1]
  def change
    add_column :broadcast_items, :top, :boolean
    add_column :broadcast_items, :bottom, :boolean
  end
end
