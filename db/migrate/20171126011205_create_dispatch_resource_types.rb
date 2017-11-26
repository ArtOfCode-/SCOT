class CreateDispatchResourceTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_resource_types do |t|
      t.string :name
      t.string :description
      
      t.timestamps
    end
  end
end
