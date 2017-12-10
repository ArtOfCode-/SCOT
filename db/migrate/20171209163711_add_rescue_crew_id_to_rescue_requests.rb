class AddRescueCrewIdToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :rescue_requests, :rescue_crew_id, :bigint, index: true
  end
end
