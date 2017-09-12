class AddUrlToAccessLogs < ActiveRecord::Migration[5.1]
  def change
    add_column :access_logs, :url, :string
  end
end
