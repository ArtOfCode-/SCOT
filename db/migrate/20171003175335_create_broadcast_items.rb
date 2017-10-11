class CreateBroadcastItems < ActiveRecord::Migration[5.1]
  def change
    create_table :broadcast_items do |t|
      t.text :content
      t.datetime :originated_at
      t.references :broadcast_municipality, foreign_key: true
      t.text :translation
      t.text :source

      t.timestamps
    end
  end
end
