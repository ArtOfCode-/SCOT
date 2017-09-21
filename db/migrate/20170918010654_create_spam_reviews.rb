class CreateSpamReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :spam_reviews do |t|
      t.references :rescue_request, foreign_key: true
      t.string :outcome
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
