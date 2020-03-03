# frozen_string_literal: true

class ForecastsController < ApplicationController
  def index
    @forecasts = Forecast.where(projection: false)
    respond_to do |format|
      format.csv { render text: @forecasts.to_csv }
    end
  end
end
