class CreateContactAttempts < ActiveRecord::Migration[5.1]
  def change
    create_table :contact_attempts do |t|
      t.references :user, foreign_key: true
      t.references :rescue_request, foreign_key: true
      t.string :medium
      t.string :outcome
      t.text :details

      t.timestamps
    end
  end
end
