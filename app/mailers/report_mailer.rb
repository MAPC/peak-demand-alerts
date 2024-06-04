# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  def daily(report)
    @report = report
    @config = ::Configuration.latest
    if ENV.fetch('ACTIVE', "false").downcase == "true"
      mailgun_vars = @report.as_json
      mailgun_vars[:possible_min] = (@config.possible_min / 1000.0).to_s
      mailgun_vars[:possible_max] = (@config.possible_max / 1000.0).to_s
      message = mail(
        from: ENV.fetch('EMAIL_FROM', 'Peak Load via MAPC <peakdemand@mapc.org>'),
        to: "peakdemand@mailgun2.mapc.org",
        subject: "Peak Demand Update - #{Date.today.strftime("%-m/%-d")}",
        template: 'peak demand alerts',
        body: "",
        'X-Mailgun-Variables' => mailgun_vars.to_json
      )
      message
    end
  end
end
