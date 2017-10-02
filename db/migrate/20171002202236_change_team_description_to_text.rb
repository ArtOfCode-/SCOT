class ChangeTeamDescriptionToText < ActiveRecord::Migration[5.1]
  def change
    change_column :people_teams, :description, :text
  end
end
