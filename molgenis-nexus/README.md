# MOLGENIS - NEXUS Helm Chart

NEXUS repository for kubernetes to deploy on a kubernetes cluster with NFS-share

## Chart Details

This chart will deploy:

- 1 NEXUS container
- 1 MOLGENIS-httpd container ()to proxy the registry and docker to one domain)

## Installing the Chart

You can test in install the chart by executing:

```helm lint .```

To test if your helm chart-syntax is right and:

```helm install . --dry-run --debug```

To test if your hem chart works and:

```helm install .```

To deploy it on the cluster.


