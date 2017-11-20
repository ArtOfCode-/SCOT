class AddMediaToDispatchRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :dispatch_requests, :media, :text
  end
end
