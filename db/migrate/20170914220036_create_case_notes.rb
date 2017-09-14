class CreateCaseNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :case_notes do |t|
      t.references :rescue_request, foreign_key: true
      t.references :user, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
