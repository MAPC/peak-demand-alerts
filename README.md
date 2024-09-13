# Peak Demand Alerts

Alerting municipalities when they can save on energy costs and help the environment.

## Deployment

This application lives on Heroku as peak-alerts. The app is automatically built/deployed when you push to the remote heroku git repository.

## Environment Variables
In addition to the environment variables defined in [.env.template](.env.template), on production you will need to set configuraiton for the [MailGun API](https://www.mailgun.com).

```sh
heroku config:set\
 MAILGUN_API_KEY='value'\
 MAILGUN_DOMAIN='value'\
 MAILGUN_PUBLIC_KEY='value'\
```

## Seasonal shut-down/start-up

### Shutting down
At the end of the summer, we can suspend emails and save money by deactivating the service in Heroku. 
1. First, go to the Settings tab for the app, and set the `ACTIVE` environment variable to `false`. This prevents emails from going out when the service is running.
2. Then, go to the Resources tab for the app, click the "edit" icon for the Dyno, and click the slider to deactivate the service. When this is done, you should see the "Estimated Monthly Cost" at the bottom read $0.00

### Starting up
At the beginning of the summer, we can resume emails by turning the service back on and making it active again.
1. First, go to the Resources tab for the app, click the "edit" icon for the Dyno, and click the slider to activate the service. When this is done, you should see the "Estimated Monthly Cost" bump up to ~$7.00 (as of 09/2024).
2. Then, go to the Settings tab for the app, and set the `ACTIVE` environment variable to `true`. This allows the daily alert emails to be sent now that the service is running again.
