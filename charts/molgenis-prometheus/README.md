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

The services are not accessable from outside the cluster, if you want to access them for debugging
purposes you need to use kubectl to port-forward them to your localhost.

For instance to access the prometheus UI:
```
kubectl port-forward molgenis-prometheus-server-podname 9090
```

## Script
If you deploy the chart on prod-molgenis than there will run a script every night at 5.30 AM there will be a 
cronjob started what will collect the production servers and will set them in the targets for prometheus to be scraped.

## Secrets
When deploying the chart for the dev-molgenis on rancher, you'll asked to fill in
* the slack api url should look like this: https://molgenisdev.slack.com/services/...
When deploying the chart for the prod-molgenis on rancher, you'll asked to fill in
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