class CreateDispatchCaseNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_case_notes do |t|
      t.bigint :request_id
      t.bigint :author_id
      t.text :content
      t.boolean :medical

      t.timestamps
    end
  end
end
