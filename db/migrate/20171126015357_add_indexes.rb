class AddIndexes < ActiveRecord::Migration[5.1]
  def change
    add_column :request_priorities, :index, :integer
    add_column :request_statuses, :index, :integer
  end
end
