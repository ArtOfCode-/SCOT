class CreateDispatchResources < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_resources do |t|
      t.string :name
      t.text :details
      t.decimal :lat
      t.decimal :long
      t.bigint :resource_type_id
      
      t.timestamps
    end
  end
end
