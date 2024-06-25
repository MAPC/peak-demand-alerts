# frozen_string_literal: true

class Report < ApplicationRecord
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
    wg_forecasts = weather_gov_forecasts
    # weather.gov forecasts have two per day: daytime and nighttime
    # Get highest temp from either forecast
    high_temp = [wg_forecasts[0][0]['temperature'], wg_forecasts[1][0]['temperature']].max
    dew_point = wg_forecasts[0][0].key?('dewpoint') ? wg_forecasts[0][0]['dewpoint']['value'] * 9 / 5 + 32 : nil # convert C to F
    humidity = wg_forecasts[0][0].key?('relativeHumidity') ? ['relativeHumidity']['value'] : nil
    forecast = forecasts.create(
      projection: false,
      high_temp: high_temp,
      dew_point: dew_point,
      humidity: humidity,
      peak_hour: DateTime.parse(peak_load['BeginDate']),
      peak_load: peak_load['LoadMw'].to_i,
      actual_peak_hour: Time.parse(morning_report['PeakLoadYesterdayHour']).hour,
      actual_peak_load: morning_report['PeakLoadYesterdayMw'],
      date: Date.current
    )

    sd_forecast = seven_day_forecast.first['MarketDay']
    weather_gov_forecasts[0][0...-1].each.with_index() do |day, index|
      high_temp = [day['temperature'], wg_forecasts[1][index]['temperature']].max
      dew_point = day.key?('dewpoint') ? day['dewpoint']['value'] * 9 / 5 + 32 : nil # convert C to F
      humidity = day.key?('relativeHumidity') ? ['relativeHumidity']['value'] : nil
      forecasts.create(projection: true,
                       high_temp: high_temp,
                       dew_point: dew_point,
                       humidity: humidity,
                       peak_load: sd_forecast[index]['PeakLoadMw'],
                       date: Date.parse(sd_forecast[index]['MarketDate']))
    end
  end

  def peak_load
    current_hourly_load.max_by { |hour| hour['LoadMw'] }
  end

  def morning_report
    url = 'https://webservices.iso-ne.com/api/v1.1/morningreport/current.json'
    request_json(url)['MorningReports']['MorningReport'].first
  end

  def weather_gov_forecasts
    url = 'https://api.weather.gov/gridpoints/BOX/68,82/forecast'
    request_json(url)['properties']['periods'].partition.with_index { |_, i| i.even? }
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

  def as_json(options={})
    {
      likely: actual_forecast.risk == :likely ? 'true' : nil,
      possible: actual_forecast.risk == :possible ? 'true' : nil,
      unlikely: actual_forecast.risk == :unlikely ? 'true' : nil,
      forecasts: forecasts[0..7].as_json
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
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
