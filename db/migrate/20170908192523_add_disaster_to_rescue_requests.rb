class AddDisasterToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_reference :rescue_requests, :disaster, foreign_key: true
  end
end
