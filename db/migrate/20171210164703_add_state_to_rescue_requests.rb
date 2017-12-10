class AddStateToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :rescue_requests, :state, :string
  end
end
