class CreateTranslations < ActiveRecord::Migration[5.1]
  def change
    create_table :translations do |t|
      t.text :content
      t.integer :source_lang_id
      t.integer :target_lang_id
      t.string :deliver_to
      t.datetime :due
      t.integer :requester_id
      t.integer :assignee_id

      t.timestamps
    end
  end
end
