class CreateBroadcastMunicipalities < ActiveRecord::Migration[5.1]
  def change
    create_table :broadcast_municipalities do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
