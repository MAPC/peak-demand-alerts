# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index
    @report = Report.latest
    @config = ::Configuration.latest
  end
end
