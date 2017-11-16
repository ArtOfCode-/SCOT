class AddCrewIdToDispatchRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :dispatch_requests, :rescue_crew_id, :bigint
  end
end
