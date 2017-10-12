class AddRequestIdToBroadcastItems < ActiveRecord::Migration[5.1]
  def change
    add_column :broadcast_items, :request_id, :integer
  end
end
