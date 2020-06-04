# Peak Demand Alerts

Alerting municipalities when they can save on energy costs and help the environment.


## Deployment

This application lives on Heroku as peak-alerts.

## Environment Variables
In addition to the environment variables defined in [.env.template](.env.template), on production you will need to set configuraiton for the [MailGun API](https://www.mailgun.com).

```sh
heroku config:set\
 MAILGUN_API_KEY='value'\
 MAILGUN_DOMAIN='value'\
 MAILGUN_PUBLIC_KEY='value'\
```
