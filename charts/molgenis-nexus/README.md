# MOLGENIS - NEXUS Helm Chart

NEXUS repository for kubernetes to deploy on a kubernetes cluster with NFS-share

## Chart Details

This chart will deploy:

- 1 NEXUS-nfs initialization container

  We need this container to avoid permission issues on the NEXUS docker
- 1 NEXUS container

## Backup restore
There are two steps in restoring the NEXUS.

- Database
- Blobstore

### Restore the database
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

### Restore the blobstore
You can copy the directory ```blobs``` to the target persistent volume ```/ blobs```.

You can now bring the NEXUS back up.

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



