class CreateMedicalConditionsRescueRequestsJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :medical_conditions, :rescue_requests do |t|
      # t.index [:medical_condition_id, :rescue_request_id]
      # t.index [:rescue_request_id, :medical_condition_id]
    end

    rename_column :rescue_requests, :medical_conditions, :medical_details
  end
end
