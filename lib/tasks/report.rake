# frozen_string_literal: true

namespace :report do
  desc 'Get the latest forecast, and send out the daily report.'
  task update: :environment do
    report = Report.create!
    mailer_response = ReportMailer.daily(report).deliver_now
    puts mailer_response.to_yaml
  end
end
