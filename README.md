# Peak Demand Alerts

Alerting municipalities when they can save on energy costs and help the environment.

<img width="733" alt="Screenshot 2024-09-13 at 12 04 10 PM" src="https://github.com/user-attachments/assets/ef2f1ab1-f708-46ad-abec-9163e91f184f">

## Overview

This is a Rails app that runs scheduled daily emails (via Mailgun). There is a [basic admin interface](https://peak-alerts.herokuapp.com/admin/) that allows us to configure the min/max values for energy consumption thresholds and view the status of today's emails. There is also a [simple embeddable page](https://peak-alerts.herokuapp.com/) that surfaces the same information as the daily emails.

Weather data are pulled from the [weather.gov API](https://www.weather.gov/documentation/services-web-api), and energy usage data are pulled from the [ISO New England Web Services API](https://webservices.iso-ne.com/docs/v1.1/).

The Environment team runs a model that predicts the min/max energy consumption for the season (managed by adding/updating [Configuration](https://github.com/MAPC/peak-demand-alerts/blob/main/app/models/configuration.rb)s through the [admin UI](https://peak-alerts.herokuapp.com/admin/). These configuration values are used to make the unlikely/possible/likely determinations in the daily email alerts.

## Scheduling
The app uses the [Heroku Scheduler add-on](https://elements.heroku.com/addons/scheduler) to run the rake task that generates today's [weather report](https://github.com/MAPC/peak-demand-alerts/blob/main/app/models/report.rb) and sends emails via Mailgun.

Note: The `ACTIVE` environment variable must be set to `true` for the emails to go out. This acts as a simple on/off switch for the service if needed.

## Emails

### Content
Originally, email content was generated using an [erb template](https://github.com/ruby/erb). Now, the app uses [Mailgun's Email Templates](https://www.mailgun.com/resources/tools/email-templates/) feature. Ideally, non-technical users should be able to manage and update the email template without requiring a code deployment or other technical assistance.

### Mailing List
Originally, the mailing list was maintained as CSV in an environment variable (`EMAIL_RECIPIENTS`). Now, the app uses Mailgun's Mailing List feature. Ideally, non-technical users should be able to manage and update the mailing list without requiring a code deployment or other technical assistance. See these Mailgun docs on the [mailing list API](https://documentation.mailgun.com/docs/mailgun/user-manual/sending-messages/#mailing-lists), [managing mailing lists](https://www.mailgun.com/blog/deliverability/email-list-management/), and [mailing list best practices](https://www.mailgun.com/blog/deliverability/how-to-build-an-email-list-the-right-way/).

Note: Unsubscribed emails should be removed regularly from the mailing list. If this is not done, the proportion of successful/unsuccessful emails may drop below the alert threshold (see the `MAILGUN_BAD_DELIVERY_THRESHOLD` environment variable) and trigger the status monitor.

### Monitoring
We use [UptimeRobot](https://dashboard.uptimerobot.com/monitors) to monitor the service itself (Peak Alerts) and the daily email delivery (Peak Demand Alert Emails). The `MAILGUN_BAD_DELIVERY_THRESHOLD` environment variable (usually set to `80`, representing 80% successfully delivered) determines whether the "Peak Demand Alert Emails" monitor will be triggered. It reads from the https://peak-alerts.herokuapp.com/status/email endpoint, which queries the Mailgun API and determines the deliverability of the most recent batch of emails sent to the mailing list.

## Deployment

This application lives on Heroku as `peak-alerts`. The app is automatically built/deployed when you push to the remote heroku git repository.

## Environment Variables
In addition to the environment variables defined in [.env.template](.env.template), on production you will need to set configuration for the [MailGun API](https://www.mailgun.com).

```sh
heroku config:set\
 MAILGUN_API_KEY='value'\
 MAILGUN_DOMAIN='value'\
 MAILGUN_PUBLIC_KEY='value'\
```

Production values for these environment variables can be found in Dashlane under the "Peak Demand" secure notes.

These variables can also be managed through the Settings tab for the app in Heroku.

## Seasonal shut-down/start-up

### Shutting down
At the end of the summer, we can suspend emails and save money by deactivating the service in Heroku.
1. First, log into [UptimeRobot](https://dashboard.uptimerobot.com/monitors) and pause the monitors (there are two: Peak Alerts and Peak Demand Alert Emails) by selecting the checkboxes next to them, going to the "Bulk actions" dropdown at the top, and selecting "Pause monitors".
2. Then, go to the Settings tab for the app, and set the `ACTIVE` environment variable to `false`. This prevents emails from going out when the service is running.
3. Lastly, go to the Resources tab for the app, click the "edit" icon for the Dyno, and click the slider to deactivate the service. When this is done, you should see the "Estimated Monthly Cost" at the bottom read $0.00

### Starting up
At the beginning of the summer, we can resume emails by turning the service back on and making it active again.
1. First, go to the Resources tab for the app, click the "edit" icon for the Dyno, and click the slider to activate the service. When this is done, you should see the "Estimated Monthly Cost" bump up to ~$7.00 (as of 09/2024).
2. Then, go to the Settings tab for the app, and set the `ACTIVE` environment variable to `true`. This allows the daily alert emails to be sent now that the service is running again.
3. Lastly, log into [UptimeRobot](https://dashboard.uptimerobot.com/monitors) and start the monitors (there are two: Peak Alerts and Peak Demand Alert Emails) by selecting the checkboxes next to them, going to the "Bulk actions" dropdown at the top, and selecting "Start monitors".
