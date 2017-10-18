class AddDefaultsToBroadcastItems < ActiveRecord::Migration[5.1]
  def change
    change_column :broadcast_items, :top, :boolean, default: false
    change_column :broadcast_items, :bottom, :boolean, default: false
  end
end
