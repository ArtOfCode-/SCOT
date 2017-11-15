class CreateReadNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :read_notifications do |t|
      t.references :notification, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
