class AddDisasterToDispatchRequests < ActiveRecord::Migration[5.1]
  def change
    add_reference :dispatch_requests, :disaster, foreign_key: true
  end
end
