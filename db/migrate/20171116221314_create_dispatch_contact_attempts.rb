class CreateDispatchContactAttempts < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_contact_attempts do |t|
      t.references :user, foreign_key: true
      t.bigint :request_id
      t.string :medium
      t.string :outcome
      t.text :details

      t.timestamps
    end
  end
end
