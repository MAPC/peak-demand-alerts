# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  def daily(report)
    @report = report
    @config = ::Configuration.latest
    mail to: 'peakdemand@mapc.org',
         from: ENV.fetch('EMAIL_FROM'),
         bcc: ENV.fetch('EMAIL_RECIPIENTS'),
         subject: "Peak Demand Update - #{Time.now.strftime('%-m/%-d')}"
  end
end
