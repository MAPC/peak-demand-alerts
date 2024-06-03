class AddDewPointToForecasts < ActiveRecord::Migration[5.2]
  def change
    add_column :forecasts, :dew_point, :integer
  end
end
