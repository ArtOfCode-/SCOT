class CreateDispatchResourceUses < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_resource_uses do |t|
      t.bigint :resource_id
      t.bigint :request_id
      t.string :purpose
      
      t.timestamps
    end
  end
end
