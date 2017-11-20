class AddIndexToDispatchRequestStatuses < ActiveRecord::Migration[5.1]
  def change
    add_column :dispatch_request_statuses, :index, :integer
  end
end
