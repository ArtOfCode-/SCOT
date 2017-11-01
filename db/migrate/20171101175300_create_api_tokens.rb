class CreateAPITokens < ActiveRecord::Migration[5.1]
  def change
    create_table :api_tokens do |t|
      t.references :user, foreign_key: true
      t.string :token
      t.string :code
      t.text :scopes

      t.timestamps
    end
  end
end
