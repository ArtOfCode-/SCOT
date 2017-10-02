class CreateVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_table :volunteers do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.date :join_date
      t.boolean :active

      t.timestamps
    end
  end
end
