class ModifyPrecisionOnLatLongRescueRequests < ActiveRecord::Migration[5.1]
  def change
    change_column :rescue_requests, :lat, :decimal, precision: 20, scale: 15
    change_column :rescue_requests, :long, :decimal, precision: 20, scale: 15
  end
end
