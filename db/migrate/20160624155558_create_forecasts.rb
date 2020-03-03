# frozen_string_literal: true

class CreateForecasts < ActiveRecord::Migration
  def change
    create_table :forecasts do |t|
      t.references :report
      t.date :date
      t.integer :high_temp
      t.integer :peak_hour
      t.integer :peak_load
      t.integer :humidity
      t.integer :heat_index
      t.decimal :temperature
      t.integer :actual_peak_hour
      t.integer :actual_peak_load
      t.string :risk
      t.boolean :projection

      t.timestamps null: false
    end
  end
end
