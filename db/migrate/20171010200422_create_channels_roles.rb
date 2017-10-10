class CreateChannelsRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :channels_roles, id: false, primary_key: [:channel_id, :role_id] do |t|
      t.integer :channel_id, null: false
      t.integer :role_id, null: false
    end
  end
end
