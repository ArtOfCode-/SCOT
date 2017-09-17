class AddMediaLinkToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :rescue_requests, :media, :string
  end
end
