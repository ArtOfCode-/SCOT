class CreateUserAuthorizations < ActiveRecord::Migration[5.1]
  def change
    create_table :user_authorizations do |t|
      t.references :resource, polymorphic: true, index: true
      t.references :user, foreign_key: true
      t.integer :granted_by_id
      t.string :valid_on
      t.text :reason
      t.datetime :expires_at

      t.timestamps
    end
  end
end