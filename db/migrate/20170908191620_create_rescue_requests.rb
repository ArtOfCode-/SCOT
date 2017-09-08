class CreateRescueRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :rescue_requests do |t|
      t.decimal :lat
      t.decimal :long
      t.integer :incident_number
      t.string :name
      t.text :address_line_1
      t.text :address_line_2
      t.string :city
      t.string :state
      t.string :country
      t.string :zip_code
      t.string :twitter
      t.string :phone
      t.string :email
      t.integer :people_count
      t.text :medical_conditions
      t.text :extra_details
      t.string :key

      t.timestamps
    end
  end
end
