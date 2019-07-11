# MOLGENIS - NEXUS Helm Chart

NEXUS repository for kubernetes to deploy on a kubernetes cluster with NFS-share

## Chart Details

This chart will deploy:

- 1 NEXUS-nfs initialization container

  We need this container to avoid permission issues on the NEXUS docker
- 1 NEXUS container


## Upgrade
Make changes in the chart. Release the chart and **make sure make sure you fill in the existing volume claim**.

## Installing the Chart

You can test in install the chart by executing:

```helm lint .```

To test if your helm chart-syntax is right and:

```helm install . --dry-run --debug```

To test if your hem chart works and:

```helm install .```

To deploy it on the cluster.

```curl -L -u xxxx:xxxx http://registry.molgenis.org/repository/helm/ --upload-file molgenis-x.x.x.tgz```

To push it to the registry



