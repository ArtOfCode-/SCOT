class CreatePeopleTeamMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :people_team_memberships do |t|
      t.references :people_volunteer, foreign_key: true
      t.references :people_team, foreign_key: true
      t.string :role

      t.timestamps
    end
  end
end
