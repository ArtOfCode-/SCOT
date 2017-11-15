class AddReadAtToReadNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :read_notifications, :read_at, :datetime
  end
end
