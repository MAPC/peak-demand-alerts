# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.date :current_date

      t.timestamps null: false
    end
  end
end
