class CreateDispatchRequestsUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_requests_users, id: :false, primary_key: [:request_id, :user_id] do |t|
      t.bigint :request_id
      t.bigint :user_id
    end
  end
end
