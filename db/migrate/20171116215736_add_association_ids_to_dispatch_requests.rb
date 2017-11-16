class AddAssociationIdsToDispatchRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :dispatch_requests, :status_id, :bigint
    add_column :dispatch_requests, :priority_id, :bigint
    add_index :dispatch_requests, :status_id
    add_index :dispatch_requests, :priority_id
  end
end
