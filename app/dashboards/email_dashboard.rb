require "administrate/custom_dashboard"

class EmailDashboard < Administrate::CustomDashboard
  resource "Emails" # used by administrate in the views
end
