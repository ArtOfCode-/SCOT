class CreateBroadcastStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :broadcast_statuses do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
