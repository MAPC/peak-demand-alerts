# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index
    @report = Report.where(created_at: Time.current.all_day).first
    @config = ::Configuration.latest
  end
end
