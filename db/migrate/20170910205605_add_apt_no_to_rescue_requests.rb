class AddAptNoToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :rescue_requests, :apt_no, :integer
  end
end
