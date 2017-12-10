class AddRequestPriorityToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_reference :rescue_requests, :request_priority, foreign_key: true
  end
end
