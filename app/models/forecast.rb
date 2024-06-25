# frozen_string_literal: true

class Forecast < ApplicationRecord
  extend Enumerize

  before_save :set_risk_category
  belongs_to :report

  validates :peak_load, presence: true

  enumerize :risk, in: %i[unlikely possible likely unknown],
                   default: :unknown

  def today?
    Time.current.beginning_of_day == date.beginning_of_day
  end

  def possible
    @range ||= Configuration.latest.possible_range
  rescue NoMethodError => e
    Rails.logger.error "No config found, falling back to null. \n #{e.message}"
    @range = Configuration.null
  end

  def peak_hour_range
    start = peak_hour.strftime('%l')
    finish = (peak_hour + 1.hour).strftime('%l %p')

    [start, finish].join(' - ')
  end

  def risk_level
    if possible.include?(peak_load) then 'possible'
    elsif peak_load < possible.min     then 'unlikely'
    elsif peak_load > possible.max     then 'likely'
    end
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |forecast|
        csv << forecast.attributes.values_at(*column_names)
      end
    end
  end

  def as_json(options={})
    {
      today: today? ? 'true' : nil,
      date: date.strftime("%a %d %b").upcase,
      high: high_temp,
      humidity: humidity.nil? ? 'N/A' : humidity,
      dewPoint: dew_point.nil? ? 'N/A' : dew_point,
      peakLoad: (peak_load.to_f / 1000).round(1),
      peakHourRange: today? ? peak_hour_range : "",
      risk: risk.upcase,
      likely: risk == :likely ? 'true' : nil,
      possible: risk == :possible ? 'true' : nil,
      unlikely: risk == :unlikely ? 'true' : nil,
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  private

  def set_risk_category
    self.risk = risk_level
  end
end
