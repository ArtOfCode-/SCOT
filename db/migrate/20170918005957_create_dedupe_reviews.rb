class CreateDedupeReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :dedupe_reviews do |t|
      t.references :rescue_request, foreign_key: true
      t.string :outcome
      t.references :user, foreign_key: true
      t.references :dupe_of, references: :rescue_requests # foreign_key: true
      t.integer :suggested_duplicates

      t.timestamps
    end
  end
end
