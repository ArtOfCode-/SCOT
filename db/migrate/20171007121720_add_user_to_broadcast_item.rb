class AddUserToBroadcastItem < ActiveRecord::Migration[5.1]
  def change
    add_reference :broadcast_items, :users, foreign_key: true
  end
end
