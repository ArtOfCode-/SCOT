class RemoveUsersFromBroadcastItemsAndAddUser < ActiveRecord::Migration[5.1]
  def change
    remove_reference :broadcast_items, :users, foreign_key: true
    add_reference :broadcast_items, :user, foreign_key: true
  end
end
