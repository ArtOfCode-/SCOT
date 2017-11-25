class AddIndexToDispatchPriorities < ActiveRecord::Migration[5.1]
  def change
    add_column :dispatch_priorities, :index, :integer
  end
end
