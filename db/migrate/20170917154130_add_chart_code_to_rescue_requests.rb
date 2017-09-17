class AddChartCodeToRescueRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :rescue_requests, :chart_code, :string
  end
end
