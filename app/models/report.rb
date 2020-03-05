# frozen_string_literal: true

class Report < ActiveRecord::Base
  after_save :scrape

  has_many :forecasts, -> { order(created_at: :asc) }

  default_scope { includes(:forecasts) }
  scope :today, lambda {
    where(created_at: (Time.current.beginning_of_day..Time.current.end_of_day))
  }

  def self.latest
    order(created_at: :asc).last
  end

  def actual_forecast
    forecasts.where(projection: false).first
  end

  def scrape
    # https://www.wunderground.com/weather/api/d/docs?d=data/conditions
    forecast = forecasts.create(
      projection: false,
      high_temp: morning_report['CityForecastDetail'].detect do |i|
        i['CityName'] == 'Boston'
      end['HighTemperature'],
      peak_hour: DateTime.parse(peak_load['BeginDate']),
      peak_load: peak_load['LoadMw'].to_i,
      actual_peak_hour: Time.parse(morning_report['PeakLoadYesterdayHour']).hour,
      actual_peak_load: morning_report['PeakLoadYesterdayMw'],
      date: Date.current
    )

    seven_day_forecast.first['MarketDay'].each do |day|
      high_temp = day['Weather']['CityWeather'].detect do |hash|
        hash['CityName'] == 'Boston'
      end['HighTempF']
      forecasts.create(projection: true,
                       high_temp: high_temp,
                       peak_load: day['PeakLoadMw'],
                       date: Date.parse(day['MarketDate']))
    end
  end

  def peak_load
    current_hourly_load.max_by { |hour| hour['LoadMw'] }
  end

  def morning_report
    url = 'https://webservices.iso-ne.com/api/v1.1/morningreport/current.json'
    request_json(url)['MorningReports']['MorningReport'].first
  end

  def current_hourly_load
    date = Time.current.strftime('%Y%m%d')
    url = "https://webservices.iso-ne.com/api/v1.1/hourlyloadforecast/day/#{date}.json"
    request_json(url)['HourlyLoadForecasts']['HourlyLoadForecast']
  end

  def seven_day_forecast
    url = 'https://webservices.iso-ne.com/api/v1.1/sevendayforecast/current.json'
    request_json(url)['SevenDayForecasts']['SevenDayForecast']
  end

  def request_json(url)
    request = RestClient::Request.execute request_params.merge({ url: url })
    JSON.parse request
  end

  private

  def request_params
    {
      method: :get,
      user: ENV.fetch('ISO_USER'),
      password: ENV.fetch('ISO_PASS'),
      verify_ssl: OpenSSL::SSL::VERIFY_NONE
    }
  end
end
