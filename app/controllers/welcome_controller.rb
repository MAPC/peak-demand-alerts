class WelcomeController < ApplicationController
	def index
		@report = Report.latest
		@forecast = @report.actual_forecast
	end
end
