# MOLGENIS - Elasticsearch
This chart is used for all possible environments at the moment.

## Containers
This chart spins up Elasticsearch instance. The created containers are:

- ElasticSearch instance (5.5.6)

## Provisioning
You can choose from which registry you want to pull. There are 2 registries:
- https://registry.molgenis.org
- https://hub.docker.com

The registry.molgenis.org contains the bleeding edge versions (PR's and master merges). The hub.docker.com contains the released artifacts (MOLGENIS releases and release candidates).

## Services
The service to communicate with the Elasticsearch instance is created on port 9300

## Persistence
You can enable persistence on your the Elasticsearch stack by specifying the following property.

- ```persistence.enabled``` default 'true'

You can also choose to retain the volume of the NFS.
- ```persistence.retain``` default 'false'

### Resolve you persistent volume
You do not know which volume is attached to your Elasticsearch instance. You can resolve this by executing:

```
kubectl get pv
```

You can now view the persistent volume claims and the attached volumes.

| NAME | CAPACITY | ACCESS | MODES | RECLAIM | POLICY | STATUS | CLAIM | STORAGECLASS | REASON | AGE |
| ---- | -------- | ------ | ----- | ------- | ------ | ------ | ----- | ------------ | ------ | --- |
| pvc-45988f55-900f-11e8-a0b4-005056a51744 | 30G | RWX | | Retain | Bound | molgenis-solverd/elasticsearch-nfs-claim | nfs-provisioner-retain | | | 33d |
| pvc-3984723d-220f-14e8-a98a-skjhf88823kk | 30G | RWO | | Delete | Bound | molgenis-test/elasticsearch-nfs-claim | nfs-provisioner | | | 33d |

You see the ```molgenis-test/molgenis-nfs-claim``` is bound to the volume: ```pvc-3984723d-220f-14e8-a98a-skjhf88823kk```.
When you want to view the data in the this volume you can go to the nfs-provisioning pod and execute the shell. Go to the directory ```export``` and lookup the directory ```pvc-3984723d-220f-14e8-a98a-skjhf88823kk```. 