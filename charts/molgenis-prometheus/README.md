# Prometheus Monitoring
This will install monitoring on your cluster. It supports legacy systems as well. So you can monitor your VM-stack with this setup.

## Chart Details
This chart will deploy a number of services:

For scraping purposes of the current cluster:

- 1 node-exporter per node to export node stats
- 1 C-Advisor on each node to export container and pod stats
- 1 Push gateway for short-lived jobs to push their metrics to

For monitoring purposes:

- 1 alert manager instance
- 1 prometheus instance

The services are not accessable from outside the cluster, if you want to access them for debugging
purposes you need to use kubectl to port-forward them to your localhost.

For instance to access the prometheus UI:
```
kubectl port-forward molgenis-prometheus-server-podname 9090
```

## Secrets
When deploying the chart you'll be asked to fill in
* the slack api url found on https://molgenisdev.slack.com/services/BFLLSRULF
* the password for the prometheus user on molgenis-metrics servers