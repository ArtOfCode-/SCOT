class AddDeprecatedToBroadcastItems < ActiveRecord::Migration[5.1]
  def change
    add_column :broadcast_items, :deprecated, :boolean, default: false
  end
end
