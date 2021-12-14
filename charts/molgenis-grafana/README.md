# Graphana graphing
Graphana instance graphically displays metrics from one or more data sources.

## Chart details
This chart will deploy a Grafana instance.

## Authentication
We use the Auth0 authentication mechanism to implement OAuth2.

You need to perform 2 steps. 

1. Register the application in https://auth.molgenis.org.
2. Configure the application in the deployment of Grafana

### Configure application in FusionAuth
You need to configure an application to be able to login via the MOLGENIS authentication server. Follow the steps below.

- Navigate to the central authentication server: https://auth.molgenis.org 
- Login using ELIXIR → UMC Groningen.
- Applications (on the left side of the screen)
  - Parameters:
    - Name / Description
    - Authorisation redirect uri (https://#grafana domain#/login/generic_oauth)
    - Check the following options on “Enabled grants”
      - Authorization token
      - Refresh token
#### Add the Grafana roles 
- Navigate to the Role-tab 
  - Add the "viewer" role
  - Add the "admin" role and check the “Super role” checkbox
- Click on save

### Enable ID-provider for application
- Navigate to the "Settings" (leftside of the screen)
- Navigate to "Identity Providers"
- Click on "umcg"
- Scroll all the way down
- Click on "Enable" for the Grafana app
- Disable on "Create registration" for Grafana app

### Configure the application in the Grafana deployment
There are several values in the `values.yml` you need to fill in based upon the Application you create in https://auth.molgenis.org.

These are the only properties you need to configure the following properties.

```ini
grafana.grafana\.ini.auth\.github.client_id=client id
grafana.grafana\.ini.auth\.github.client_secret=client secret
```