class AddQueueColumnsToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :rescue_requests, :dupe_of, :integer
    add_column :rescue_requests, :spam, :boolean
  end
end
