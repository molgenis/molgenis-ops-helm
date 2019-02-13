# MOLGENIS
This chart is used to deploy the MOLGENIS rancher catalog app.

## Containers
This chart spins up a MOLGENIS instance. The created pods are:

- MOLGENIS
- ElasticSearch
- PostgreSQL
- Minio

Passwords will be stored as secrets in the namespace.

## Questions
When you launch the catalog app, you are presented with a set of questions to answer about your
deployment.
If you select the advanced mode, you'll get more detailed questions to fine-tune the deployment.

### Consistency
Some of the answers need to be compatible with each other, rancher does not provide us with an easy
way to check this.

* The environment you specify needs to match the cluster you're deploying to, otherwise the DNS
resolution will fail.

* The MOLGENIS docker image tag you specify needs to match the registry you choose. The bleeding edge images
like pull request previews and master snapshots can be found on `registry.molgenis.org`, the
released images reside on `registry.hub.docker.com`.

* The elasticsearch java opts allow you to fine-tune the JVM heap size. Make sure you set it to about
half the max elasticsearch container memory.

* Resource reservations should always be less than or equal to the corresponding limits.

* You can auto-generate passwords but in some really wild cases the downstream
images may not be compatible with special characters in the password.
Specifically, the admin password will get parsed by the property evaluator and
specifying `${blah}` as a password will cause your MOLGENIS installation not to boot.

## Resolve your persistent volume
You do not know which volume is attached to your MOLGENIS instance. You can resolve this by executing:

```
kubectl get pv
```

You can now view the persistent volume claims and the attached volumes.

| NAME | CAPACITY | ACCESS | MODES | RECLAIM | POLICY | STATUS | CLAIM | STORAGECLASS | REASON | AGE |
| ---- | -------- | ------ | ----- | ------- | ------ | ------ | ----- | ------------ | ------ | --- |
| pvc-45988f55-900f-11e8-a0b4-005056a51744 | 30G | RWX | | Retain | Bound | molgenis-solverd/molgenis-nfs-claim | nfs-provisioner-retain | | | 33d |
| pvc-3984723d-220f-14e8-a98a-skjhf88823kk | 30G | RWO | | Delete | Bound | molgenis-test/molgenis-nfs-claim | nfs-provisioner | | | 33d |

You see the ```molgenis-test/molgenis-nfs-claim``` is bound to the volume: ```pvc-3984723d-220f-14e8-a98a-skjhf88823kk```.
When you want to view the data in the this volume you can go to the nfs-provisioning pod and execute the shell. Go to the directory ```export``` and lookup the directory ```pvc-3984723d-220f-14e8-a98a-skjhf88823kk```. 