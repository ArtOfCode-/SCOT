class CreateDispatchRequestStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :dispatch_request_statuses do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
