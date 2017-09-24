class AddAssigneeToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :rescue_requests, :assignee_id, :integer
  end
end
