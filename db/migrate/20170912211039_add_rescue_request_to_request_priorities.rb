class AddRescueRequestToRequestPriorities < ActiveRecord::Migration[5.1]
  def change
    add_reference :request_priorities, :rescue_request, foreign_key: true
  end
end
