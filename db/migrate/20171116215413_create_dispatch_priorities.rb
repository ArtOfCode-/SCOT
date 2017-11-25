class CreateDispatchPriorities < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_priorities do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
