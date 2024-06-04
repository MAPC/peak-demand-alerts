# frozen_string_literal: true

require 'administrate/base_dashboard'

class ForecastDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    report: Field::BelongsTo,
    id: Field::Number,
    date: Field::DateTime,
    high_temp: Field::Number,
    peak_hour: Field::DateTime,
    peak_load: Field::Number,
    humidity: Field::Number,
    dew_point: Field::Number,
    heat_index: Field::Number,
    temperature: Field::String.with_options(searchable: false),
    actual_peak_hour: Field::Number,
    actual_peak_load: Field::Number,
    risk: Field::String,
    projection: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    report
    id
    date
    high_temp
    peak_hour
    peak_load
    humidity
    dew_point
    heat_index
    temperature
    actual_peak_hour
    actual_peak_load
    risk
    projection
    created_at
    updated_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    report
    id
    date
    high_temp
    peak_hour
    peak_load
    humidity
    dew_point
    heat_index
    temperature
    actual_peak_hour
    actual_peak_load
    risk
    projection
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [].freeze

  # Overwrite this method to customize how forecasts are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(forecast)
  #   "Forecast ##{forecast.id}"
  # end
end
