# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  def daily(report)
    @report = report
    @config = ::Configuration.latest
    if ENV.fetch('ACTIVE', "false").downcase == "true"
      message = mail(
        from: "peakdemand@mapc.org",
        to: "peakdemand@mailgun2.mapc.org",
        subject: "Peak Demand Update - #{Date.today.strftime("%-m/%-d")}",
        template: 'peak demand alerts',
        body: "",
        'X-Mailgun-Variables' => @report.to_json
      )
      message
    end
  end
end
