# Prometheus Monitoring
This will install monitoring on your cluster. It supports legacy systems as well. So you can monitor your VM-stack with this setup. This include kubernetes monitoring as well.

In general the prometheus chart will monitor the kubernetes services and the kubernetes nodes. If you deploy the chart, you will be required to choose between development and production.

If you choose development, you will deploy only the kubernetes monitoring. This will exclude the monitoring for the VM's. This is meant for the development on the development cluster. This will include the kubernetes and PostgreSQL alerts. You are required to fill in the slack url for development. This should be: https://hooks.slack.com/services/...

If you choose production, you will deploy the kubernetes monitoring and the VM's monitoring. This include the alerts for kubernetes, PostgreSQL and VM's alerts. The VM scrapes are automatic populated via a cronjob. The cronjob will be scheduled every day at 7 o'clock. For the cronjob to succeed, you need to have a valid github token of molgenis. If you deploy the chart for production on the production cluster, then you are required to fill in a valid github token of molgenis and you need to fill in a slack url for production. This should look like: https://molgenisops.slack.com/services/...

## Chart Details
This chart will deploy a number of services:

For scraping purposes of the current cluster:

- 1 kubeStateMetrics
- 1 C-Advisor on each node to export container and pod stats
- 1 Push gateway for short-lived jobs to push their metrics to

For monitoring purposes:

- 1 alert manager instance
- 1 prometheus instance

## Script
If you deploy the chart on prod-molgenis, each night a script will run at 6.30 AM that starts a cronjob that will collect the production servers and sets them in the targets list for prometheus to scrape.

## Secrets
When deploying the chart for the dev-molgenis on rancher, you'll be asked to fill in
* the slack api url should look like this: https://molgenisdev.slack.com/services/...
When deploying the chart for the prod-molgenis on rancher, you'll be asked to fill in
* the slack api url should look like: https://molgenisops.slack.com/services/...
* the github token for the molgenis github user(jenkins)

## Alerts
If you want to add or remove alerts from prometheus, you will need to edit the configmap with the alerts.
1. Go to: https://rancher.molgenis.org:7777
2. Login with your RuG account
3. If you want to change the production prometheus, go to: molgenis-prod -> prod-molgenis
   If you want to change the development prometheus, go to: devcluster -> dev-molgenis
4. Under the tab "Apps" go to molgenis-prometheus
5. At the bottom of the page you will find three Config maps, click on "molgenis-prometheus-serverfiles-configmap"
6. Click on the three dots on the topside and select "Edit"
### To Delete alert(s)
7. Search for the alert you want to delete, start selecting from the point where you see "- alert ..." untill you hit the next "- alert" and delete it
8. Repeat step 7 if needed and click "Save". The changed alerts will be automaticly picked up by the molgenis-prometheus.
### To add alert(s)
7. Add a newline after an alert. Make sure that you start with the same spacing as the alert above. Make sure that you use summary and description in the annotations section, if you don't use the summary and description you will not see the alert!
8. Repeat step 7 if needed and click "Save". The changed alerts will be automaticly picked up by the molgenis-prometheus.

If you want to debug or mute alert(s) services like alert manager or the prometheus server you will need to port-forward because the services are not accessible from outside the cluster. For muting alert(s) you need to forward a port to the alert manager. For debugging you can forward port(s) to alert manager and/or prometheus server. To do this you will need to have open a commandline interface.

If you want to access the prometheus server UI:
```
rancher kubectl port-forward molgenis-prometheus-server-podname 9090:9090 --namespace molgenis-prometheus
```

If you want to access the alert manager UI(silencing alert(s))
```
rancher kubectl port-forward molgenis-prometheus-alertmanager-podname 9093:9093 --namespace molgenis-prometheus
```

The pod is now available at: http://localhost:port in your browser. To close the connection you need to break the command in the commandline interface by pressing the shortcut on your keyboard: control + c

## Upgrading the chart
If you want to upgrade the chart, please keep in mind that every scrape config and (silenced) alert will be overwritten. To keep the (silenced) alerts and scrape configs you will need to backup the configmaps targets-configmap, serverfiles-configmap and alertmanager-configmap. When you upgraded the chart, overwrite the default configmaps with your stored configmaps.

Note: you don't have to backup the scrape configs because a cronjob is set to replace the scrape configs every day at 7:30 hour utc.
