class CreateNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :content
      t.datetime :expires_at

      t.timestamps
    end
  end
end
