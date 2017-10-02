class CreatePeopleRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :people_roles do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
