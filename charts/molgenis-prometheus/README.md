# Prometheus Monitoring
This will install monitoring on your kubernetes cluster. It monitors deployments on the cluster and plain VM's.

In general the prometheus-chart will monitor the kubernetes deployments and the kubernetes nodes. If you deploy the chart, you will be required to choose between development or production.

**Development**
In development-mode you will deploy only the kubernetes monitoring. This will exclude the monitoring for the VM's. This is meant for the development on the development cluster. This will include the kubernetes and PostgreSQL alerts. You are required to fill in the slack url for development. This should be: https://hooks.slack.com/services/...

**Production**
In production-mode you will deploy only the VM's monitoring. This includes only VM's alerts. The included VM's are autmopatically populated via a kubernetes cronjob. The inventories in the ansible-playbook are the source of the monitored VM's. The cronjob will be scheduled every day at 7 o'clock. For the cronjob to succeed, you need to have a valid github-token for the molgenis github-user. If you deploy the chart for production on the production cluster, you need the same token and you are obligated to fill in a slack-url for production. This should look like: https://molgenisops.slack.com/services/...

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
* the github-token for the molgenis github-user

## Alerts
If you want to add or remove alerts from prometheus, you will need to edit the configmap with the alerts.
1. Go to: https://rancher.molgenis.org:7777
2. Login with your RuG account
3. If you want to change the production prometheus, go to: molgenis-prod -> prod-molgenis
   If you want to change the development prometheus, go to: devcluster -> dev-molgenis
4. Under the tab "Apps" go to molgenis-prometheus
5. At the bottom of the page you will find three Config maps, click on "molgenis-prometheus-serverfiles-configmap"
6. Click on the three dots on the topside and select "Edit"

### Delete alerts
7. Search for the alert you want to delete, start selecting from the point where you see "- alert ..." untill you hit the next "- alert" and delete it
8. Repeat step 7 if needed and click "Save". The changed alerts will be automaticly picked up by the molgenis-prometheus.

### Add alerts
7. Add a newline after an alert. Make sure that you start with the same spacing as the alert above. Make sure that you use summary and description in the annotations section, if you don't use the summary and description you will not see the alert!
8. Repeat step 7 if needed and click "Save". The changed alerts will be automaticly picked up by the molgenis-prometheus.

If you want to debug or mute alert(s) services like alert manager or the prometheus server you will need to port-forward because the services are not accessible from outside the cluster. For muting alert(s) you need to forward a port to the alert manager. For debugging you can forward port(s) to alert manager and/or prometheus server. To do this you will need to have open a commandline interface.

## Access services locally
If you want to access the prometheus server UI:
```
rancher kubectl port-forward molgenis-prometheus-server-podname 9090:9090 --namespace molgenis-prometheus
```

If you want to access the alert manager UI (silencing alert(s))
```
rancher kubectl port-forward molgenis-prometheus-alertmanager-podname 9093:9093 --namespace molgenis-prometheus
```

The pod is now available at: http://localhost:port in your browser. To close the connection you need to break the command in the commandline interface by pressing the shortcut on your keyboard: ```control + c```

## Upgrading the chart
If you want to upgrade the chart, please keep in mind that every scrape config and (silenced) alert will be overwritten. To keep the (silenced) alerts and scrape configs you will need to backup the configmaps targets-configmap, serverfiles-configmap and alertmanager-configmap. When you upgraded the chart, overwrite the default configmaps with your stored configmaps.

> note: you don't have to backup the scrape configs because a cronjob is set to replace the scrape configs every day at 7:30 hour UTC.

Things to know:
1. In values.yml in the section prometheus-blackbox-exporter are two modules defined. Namely "http_2xx" and "http_api_2xx". The chart use the http_2xx to look and see if the VM is online or not. The http_api_2xx is ment for a api call to the api/v2/version and see if the VM respond with the buildDate and molgenisVersion. But VM's of the 0.1 branch are old and not every VM has the version call for the version. So as long as there are VM's in the 0.1 branch, it is recommended to use http_2xx instead of http_api_2xx because there are servers who dont have a api call to the version.
2. In the testing phase of the chart we experienced that if you port-forward the prometheus server and look at the targets( http://localhost:9090/targets ( assuming that the cronjob has been running for at least once and filled the necessary configmaps )) that you everything with the status "UP". This status is not the status of the VM, this is only the status of the blackbox_exporter. To see if the status of the VM frontpage is 200( working ), go to http://localhost:9090/graph and type: "probe_success" or "probe_http_status_code" and press "Execute". With "probe_success" you need to see Value: 1 and with "probe_http_status_code" you need to see Value: 200.
3. In values.yml: if the regex by http_api_2xx is not working
```fail_if_body_not_matches_regexp:
  - "^.*buildDate.*molgenisVersion.*$"```, replace it with: 
```fail_if_body_not_matches_regexp: "^.*buildDate.*molgenisVersion.*$"```. Also make sure you use: "<VM>/api/v2/version" and that the requested link is available( see point 1 ).