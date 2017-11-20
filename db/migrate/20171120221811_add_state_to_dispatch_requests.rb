class AddStateToDispatchRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :dispatch_requests, :state, :string
  end
end
