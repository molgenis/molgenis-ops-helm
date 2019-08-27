# Troubleshooting

## Restore a backup
There are 2 ways to restore data in the NEXUS.
- a restore of the persistent volume
- a complete restore of all the data

### Restore of the persistent volume
We start with the ```storageClass```-type of the ```persistent volume``` (from now on referred as ```pv```) you add to the Nexus. The pv of the Nexus instance should always be ```retain```. 
That way you can easily delete and redeploy the instance. The following procedure lets you reclaim the retained pv when the Nexus deployment is killed.

First of all you need to remove the ```claimRef``` in the target ```pv```.


```bash
## get all persistent volumes

kubectl get pv | grep molgenis-nexus

NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                                         STORAGECLASS             REASON    AGE
pvc-29f58f40-3b3e-11e9-879d-005056b2844c   10Gi       RWO            Delete           Bound     molgenis-dwgqr/data-biobank-postgresql-0      nfs-provisioner-delete             14d
pvc-4a3c30b4-2f6b-11e9-879d-005056b2844c   5Gi        RWO            Delete           Bound     molgenis/data-sido-postgresql-0               nfs-provisioner-delete             30d
pvc-b7765e8e-465b-11e9-9352-005056b2844c   8Gi        RWO            Retain           Bound     molgenis-nexus-sidos/pvc-molgenis-nexus       nfs-provisioner-retain             20h
pvc-fa30c707-41b9-11e9-879d-005056b2844c   5Gi        RWO            Delete           Bound     molgenis-nexus-xvhmp/molgenis-nexus-xvhmp     nfs-provisioner-delete             6d

## Choose the volume you want to edit

kubectl edit pv pvc-b7765e8e-465b-11e9-9352-005056b2844c 
```

Delete the following part in the ```pv.yaml```.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/bound-by-controller: "yes"
    pv.kubernetes.io/provisioned-by: cluster.local/nfs-client-provisioner
  creationTimestamp: 2019-03-14T13:18:59Z
  finalizers:
  - kubernetes.io/pv-protection
  name: pvc-b7765e8e-465b-11e9-9352-005056b2844c
  resourceVersion: "7210901"
  selfLink: /api/v1/persistentvolumes/pvc-b7765e8e-465b-11e9-9352-005056b2844c
  uid: ba388f0b-465b-11e9-8fc9-005056b2f79d
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 8Gi
  ## START DELETE
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: molgenis-nexus
    namespace: molgenis-nexus
    resourceVersion: "7210898"
    uid: 4d83e691-4660-11e9-9352-005056b2844c
  ## STOP DELETE
  nfs:
    path: /molgenis-nexus-xbxpn-molgenis-nexus-xbxpn-pvc-b7765e8e-465b-11e9-9352-005056b2844c
    server: 192.168.64.160
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs-provisioner-retain
  volumeMode: Filesystem
status:
  phase: Released
```

Save the changes in the ```pv.yaml```. The status should now be ```Available```

When you deleted this part you need to delete the namespace ```molgenis-nexus```

```bash
kubectl delete namespace molgenis-nexus
```

When you deleted the namespace you need to recreate on in the target project ```prod-molgenis``` using the rancher client.

```bash
rancher namespaces create molgenis-nexus
```

Then import the following ```persistent volume claim``` (from now on referred as ```pvc```) to rebind the pv. 

The ```pvc.yaml``` should look like this.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: molgenis-nexus
  namespace: molgenis-nexus
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
  storageClassName: nfs-provisioner-retain
  volumeName: pvc-b7765e8e-465b-11e9-9352-005056b2844c
```

Make sure the ```name```, ```namespace```, ```storageClassName``` and ```volumeName``` are corresponding with the persistent volume definition. 

```bash
kuebctl create -f pvc.yaml
```

Now you can enter in the Nexus chart the ```existingClaimName```. It should now refer to the ```name``` of the ```pvc```.

>note: IMPORTANT make sure you deploy the chart in the ```molgenis-nexus``` namespace you created.

## Complete restore of all the data from scratch
There are two steps in restoring the NEXUS.

- Database
- Blobstore

#### Restore the database
>note: https://help.sonatype.com/repomanager3/backup-and-restore/restore-exported-databases 
 
Go to a shell:

```bash
kubectl get pv | grep molgenis-nexus
```

```bash
| NAME | CAPACITY | ACCESS | MODES | RECLAIM | POLICY | STATUS | CLAIM | STORAGECLASS | REASON | AGE |
| ---- | -------- | ------ | ----- | ------- | ------ | ------ | ----- | ------------ | ------ | --- |
| pvc-45988f55-900f-11e8-a0b4-005056a51744 | 30G | RWX | | Retain | Bound | molgenis-nexus/molgenis-nfs-claim | nfs-provisioner-retain | | | 33d |
| pvc-3984723d-220f-14e8-a98a-skjhf88823kk | 30G | RWO | | Delete | Bound | molgenis-test/molgenis-nfs-claim | nfs-provisioner | | | 33d |
```

The persistent volume is the one in the molgenis-nexus namespace. 

Go to the NFS-provisioner to the path of the persistent volume:

List all the latest backups.
```bash
ls -t | head -6
```

Copy the latest files in the destination directory.
```bash
ls -t | head -6 | xargs -I{} cp "{}" ../#target-pv#/restore-from-backup/
```

#### Restore the blobstore
You can copy the directory ```blobs``` to the target persistent volume ```/blobs```.

#### Remove all old data files from nexus-data/db

Remove the following directories:

- accesslog
- analytics
- audit
- component
- config
- security

You can now bring the NEXUS back up.
