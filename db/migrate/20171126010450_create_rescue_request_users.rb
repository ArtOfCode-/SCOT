class CreateRescueRequestUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :rescue_request_users, id: :false, primary_key: [:rescue_request_id, :user_id] do |t|
      t.bigint :rescue_request_id
      t.bigint :user_id
    end
  end
end
