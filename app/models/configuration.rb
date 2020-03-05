# frozen_string_literal: true

class Configuration < ActiveRecord::Base
  def self.latest
    order(created_at: :asc).last
  end

  def possible_range
    Range.new(possible_min, possible_max)
  end

  def self.null
    new(possible_min: 0, possible_max: 0)
  end
end
