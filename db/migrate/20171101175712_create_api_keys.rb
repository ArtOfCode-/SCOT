class CreateAPIKeys < ActiveRecord::Migration[5.1]
  def change
    create_table :api_keys do |t|
      t.string :name
      t.string :key
      t.text :description

      t.timestamps
    end
  end
end
