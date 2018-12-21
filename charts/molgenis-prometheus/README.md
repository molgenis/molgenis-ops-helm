# Prometheus Monitoring
This will install monitoring on your cluster. It supports legacy systems as well. So you can monitor your VM-stack woith this setup.

## Chart Details
This chart will deploy a number of services:

For scraping purposes:

- 1 node-exporter on each node to export node stats
- 1 C-Advisor on each node to export container and pod stats

For monitoring purposes:

- 1 alert manager instance
- 1 prometheus instance

For viewing purposes:

- 1 grafana instance

## Installing the chart
You need to supply the following answers in Rancher or override the following values:   

- ```grafana.adminUser: admin (default)```
- ```grafana.adminPassword: strongpassword```

## Authentication
We delegate authentication to Github. You can find the callback url here: http://docs.grafana.org/auth/generic-oauth/. You need to set these variables to make this work:

- ```grafana.grafana.ini.auth.github.client_id: app id```
- ```grafana.grafana.ini.auth.github.client_secret: secret```



