# frozen_string_literal: true

class CreateConfigs < ActiveRecord::Migration
  def change
    create_table :configs do |t|
      t.integer :possible_min
      t.integer :possible_max

      t.timestamps null: false
    end
  end
end
