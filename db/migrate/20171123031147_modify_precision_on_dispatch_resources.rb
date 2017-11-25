class ModifyPrecisionOnDispatchResources < ActiveRecord::Migration[5.1]
  def change
    change_column :dispatch_resources, :lat, :decimal, precision: 20, scale: 15
    change_column :dispatch_resources, :long, :decimal, precision: 20, scale: 15
  end
end
