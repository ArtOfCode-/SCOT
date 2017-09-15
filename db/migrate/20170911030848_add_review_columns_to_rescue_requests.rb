class AddReviewColumnsToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :rescue_requests, :needs_deduping, :boolean
    add_column :rescue_requests, :needs_spam_check, :boolean
    add_column :rescue_requests, :needs_validation, :boolean
  end
end
