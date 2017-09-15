class CreateReviewTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :review_tasks do |t|
      t.string :review_type
      t.references :user, foreign_key: true
      t.references :rescue_request, foreign_key: true
      t.string :outcome

      t.timestamps
    end
  end
end
