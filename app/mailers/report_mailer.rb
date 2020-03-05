# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.report.daily.subject
  #
  def daily(report)
    @report = report
    @config = ::Configuration.latest
    # TODO: Add recipients, email setting to admin
    mail to: 'peakdemand@mapc.org',
         from: ENV.fetch('EMAIL_FROM'),
         bcc: ENV.fetch('EMAIL_RECIPIENTS'),
         subject: "Peak Demand Update - #{Time.now.strftime('%-m/%-d')}"
  end
end
