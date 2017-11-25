class CreateDispatchCrewStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_crew_statuses do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
