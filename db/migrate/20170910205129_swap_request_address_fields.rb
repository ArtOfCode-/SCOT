class SwapRequestAddressFields < ActiveRecord::Migration[5.1]
  def change
    remove_column :rescue_requests, :address_line_1
    remove_column :rescue_requests, :address_line_2
    remove_column :rescue_requests, :state
    add_column :rescue_requests, :street_address, :string
  end
end
