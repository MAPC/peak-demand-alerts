# frozen_string_literal: true

namespace :report do
  desc 'Get the latest forecast, and send out the daily report.'
  task update: :environment do
    report = Report.create!
    ReportMailer.daily(report).deliver
  end
end
