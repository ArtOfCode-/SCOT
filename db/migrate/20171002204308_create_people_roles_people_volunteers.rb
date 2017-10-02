class CreatePeopleRolesPeopleVolunteers < ActiveRecord::Migration[5.1]
  def change
    create_table :people_roles_people_volunteers, primary_key: [:people_role_id, :people_volunteer_id] do |t|
      t.integer :people_role_id, null: false
      t.integer :people_volunteer_id, null: false
    end
  end
end
