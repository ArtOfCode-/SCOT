class CreateAccessLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :access_logs do |t|
      t.references :user, foreign_key: true
      t.string :action
      t.references :resource, polymorphic: true

      t.timestamps
    end
  end
end
