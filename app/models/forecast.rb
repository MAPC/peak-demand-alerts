# frozen_string_literal: true

class Forecast < ActiveRecord::Base
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

  private

  def set_risk_category
    self.risk = risk_level
  end
end
