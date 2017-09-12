class CreateRequestPriorities < ActiveRecord::Migration[5.1]
  def change
    create_table :request_priorities do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
