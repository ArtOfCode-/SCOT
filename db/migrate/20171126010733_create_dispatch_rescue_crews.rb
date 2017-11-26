class CreateDispatchRescueCrews < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_rescue_crews do |t|
      t.string :contact_name
      t.string :contact_phone
      t.string :contact_email
      t.string :callsign
      t.boolean :medical
      t.integer :capacity

      t.timestamps
    end

    add_column :rescue_requests, :rescue_crew_id, :bigint
  end
end
