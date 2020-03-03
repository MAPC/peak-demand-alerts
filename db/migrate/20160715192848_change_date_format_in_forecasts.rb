# frozen_string_literal: true

class ChangeDateFormatInForecasts < ActiveRecord::Migration
  def up
    remove_column :forecasts, :peak_hour
    add_column :forecasts, :peak_hour, :datetime
   end

  def down
    remove_column :forecasts, :peak_hour
    add_column :forecasts, :peak_hour, :integer
  end
end
