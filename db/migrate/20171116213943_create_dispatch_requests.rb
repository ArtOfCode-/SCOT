class CreateDispatchRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_requests do |t|
      t.decimal :lat
      t.decimal :long
      t.string :name
      t.string :city
      t.string :country
      t.string :zip_code
      t.string :twitter
      t.string :phone
      t.string :email
      t.integer :people_count
      t.text :medical_details
      t.text :extra_details
      t.string :key
      t.string :street_address
      t.string :apt_no
      t.string :source
      t.string :chart_code
      t.bigint :dupe_of

      t.timestamps
    end
  end
end
