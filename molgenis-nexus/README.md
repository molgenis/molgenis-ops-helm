# MOLGENIS - NEXUS Helm Chart

NEXUS repository for kubernetes to deploy on a kubernetes cluster with NFS-share

## Chart Details

This chart will deploy:

- 1 NEXUS-nfs initialization container

  We need this container to avoid permission issues on the NEXUS docker
- 1 NEXUS container
- 1 MOLGENIS-httpd container (to proxy the registry and docker to one domain)

## Backup restore

Go to the commandline:

```bash
kubectl get pv
```

```bash
| NAME | CAPACITY | ACCESS | MODES | RECLAIM | POLICY | STATUS | CLAIM | STORAGECLASS | REASON | AGE |
| ---- | -------- | ------ | ----- | ------- | ------ | ------ | ----- | ------------ | ------ | --- |
| pvc-45988f55-900f-11e8-a0b4-005056a51744 | 30G | RWX | | Retain | Bound | molgenis-nexus/molgenis-nfs-claim | nfs-provisioner-retain | | | 33d |
| pvc-3984723d-220f-14e8-a98a-skjhf88823kk | 30G | RWO | | Delete | Bound | molgenis-test/molgenis-nfs-claim | nfs-provisioner | | | 33d |
```

The persistent volume is the one in the molgenis-nexus namespace. 

Go to the NFS-provisioner to the path of the persistent volume:

```bash
ls -t --full-time | head -7 | xargs cp ../restore-from-backup/
```


## Installing the Chart

You can test in install the chart by executing:

```helm lint .```

To test if your helm chart-syntax is right and:

```helm install . --dry-run --debug```

To test if your hem chart works and:

```helm install .```

To deploy it on the cluster.


