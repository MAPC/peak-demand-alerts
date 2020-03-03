# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # default from: "mgardner@mapc.org"
  layout 'mailer'
  helper ApplicationHelper
end
