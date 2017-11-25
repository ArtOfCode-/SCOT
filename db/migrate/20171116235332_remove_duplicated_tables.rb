class RemoveDuplicatedTables < ActiveRecord::Migration[5.1]
  def change
    drop_table :case_notes
    drop_table :contact_attempts
    drop_table :medical_conditions_rescue_requests
    drop_table :medical_conditions
    drop_table :request_priorities
    drop_table :dedupe_reviews
    drop_table :spam_reviews
    drop_table :rescue_requests
    drop_table :request_statuses
    drop_table :medical_statuses
  end
end
