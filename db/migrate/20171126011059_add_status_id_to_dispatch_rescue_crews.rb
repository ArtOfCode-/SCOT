class AddStatusIdToDispatchRescueCrews < ActiveRecord::Migration[5.1]
  def change
    add_column :dispatch_rescue_crews, :status_id, :bigint
  end
end
