class AddActiveToDisasters < ActiveRecord::Migration[5.1]
  def change
    add_column :disasters, :active, :boolean
  end
end
