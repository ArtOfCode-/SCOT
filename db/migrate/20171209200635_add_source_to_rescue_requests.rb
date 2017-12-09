class AddSourceToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :rescue_requests, :source, :string
  end
end
