class AddStatusIdToBroadcastItems < ActiveRecord::Migration[5.1]
  def change
    add_column :broadcast_items, :status_id, :bigint
  end
end
