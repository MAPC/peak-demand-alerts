class Forecast < ActiveRecord::Base

	extend Enumerize

  before_save :set_risk_category
	belongs_to :report

	validates :peak_load, presence: true

	enumerize :risk, in: [:unlikely, :possible, :likely, :unknown],
    default: :unknown

  def possible
    @range ||= Config.latest.possible_range
  rescue NoMethodError => e
    Rails.logger.error "No config found, falling back to null. \n #{e.message}"
    @range = Config.null
  end

  def risk_level
    case
    when possible.include?(peak_load) then "possible"
    when peak_load < possible.min     then "unlikely"
    when peak_load > possible.max     then "likely"
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
