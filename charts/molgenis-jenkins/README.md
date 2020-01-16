# Molgenis Jenkins Helm Chart

Jenkins master and slave cluster utilizing the Jenkins Kubernetes plugin.
Wraps [the kuberenetes jenkins chart](https://github.com/kubernetes/charts/tree/master/stable/jenkins), see documentation there!

## Chart Details

This chart will do the following:

* 1 x Jenkins Master with port 8080 exposed on an external ClusterIP
* All using Kubernetes Deployments

## Installing the Chart

Usually, you'll be deploying this to the molgenis cluster.
In the [Rancher Catalog](https://rancher.molgenis.org:7443/g/catalog), add the latest version of this repository.
In the [molgenis cluster management page](https://rancher.molgenis.org:7443/p/c-mhkqb:project-2pf45/apps), choose the 
catalog, pick the molgenis-jenkins app from the catalog and deploy it.

## Configuration

When deploying, you can paste values into the Rancher Answers to override the defaults in this chart.
Array values can be added as {value, value, value}.
```
jenkins.master.ingress.hostName=jenkins.dev.molgenis.org
jenkins.master.adminPassword=pa$$word
jenkins.Persistence.Enabled=false
jenkins.master.installPlugins={kubernetes:1.8.4, workflow-aggregator:2.5, workflow-job:2.21, credentials-binding:1.16, git:3.9.1, blueocean:1.6.2, github-oauth:0.29}

# Global git config
jenkins.Master.git.name=MOLGENIS Jenkins
jenkins.Master.git.user=molgenis+ci@gmail.com
```

You can use [all configuration values of the jenkins subchart](https://github.com/kubernetes/charts/tree/master/stable/jenkins).
> Because we use jenkins as a sub-chart, you should prefix all value keys with `jenkins`!

### GitHub Authentication delegation
You need to setup a MOLGENIS - Jenkins GitHub OAuth App. You can do this by accessing this url: [add new OAuth app](https://github.com/settings/applications/new).

### Secrets
   When deployed, the chart creates a couple of kubernetes secrets that get used by jenkins.

   You can override the values at deploy time but otherwise also configure them 
   [in Rancher](https://rancher.molgenis.org:7443/p/c-mhkqb:project-2pf45/secrets) or through kubectl.

#### Vault

The vault secret gets mounted in the vault pod so pipeline scripts can retrieve secrets from the vault.

| Parameter                 | Description                                | Default                                        |
| ------------------------- | ------------------------------------------ | ---------------------------------------------- |
| `secret.vault.token`      | Token to log into the hashicorp vault      | `xxxx`                                         |
| `secret.vault.addr`       | Address of the vault                       | `https:vault-operator.vault-operator.svc:8200` |
| `secret.vault.skipVerify` | Skip verification of the https connection  | `1`                                            |

#### GitHub

Token used by Jenkins to authenticate on GitHub.

| Parameter             | Description              | Default            |
| --------------------- | ------------------------ | ------------------ |
| `secret.gitHub.user`  | username for the account | `molgenis-jenkins` |
| `secret.gitHub.token` | token for the account    | `xxxx`             |

#### Slack
The Slack integration is done mostly in the Jenkinsfile of each project. It is sufficient to only add the plugin to the Jenkins configuration in Helm.

#### Prometheus
A scraping endpoint is made available on /prometheus/
| Parameter             | Description                 | Default      |
| --------------------- | --------------------------- | ------------ |
| `Master.metrics.key`  | access key for the endpoint | none created |

#### Legacy:

##### Docker Hub
   
Account used in pipeline builds to push docker images to `hub.docker.com`.
> They should read `secret/gcc/account/dockerhub` from vault instead!

| Parameter                   | Description              | Default         |
| --------------------------- | ------------------------ | --------------- |
| `secret.dockerHub.user`     | username for the account | `molgenisci`    |
| `secret.dockerHub.password` | password for the account | `xxxx`          |

##### Registry
   
Account used in pipeline builds to push docker images to `registry.molgenis.org`.
> They should read `secret/ops/account/nexus` from vault instead!

| Parameter                   | Description              | Default   |
| --------------------------- | ------------------------ | --------- |
| `secret.registry.user`     | username for the account | `admin`   |
| `secret.registry.password` | password for the account | `xxxx`    |

## Command line use
Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.
For example,

```bash
$ helm install --name jenkins -f values.yaml molgenis-jenkins
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Restore persistence
We start with the ```storageClass```-type of the ```persistent volume``` (from now on referred as ```pv```) you add to the Jenkins. The pv of the Jenkins instance should always be ```retain```. 
That way you can easily delete and redeploy the instance. The following procedure lets you reclaim the retained pv when the Jenkins deployment is killed.

First of all you need to remove the ```claimRef``` in the target ```pv```.


```bash
## get all persistent volumes

kubectl get pv | grep molgenis-jenkins

NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM                                         STORAGECLASS             REASON    AGE
pvc-29f58f40-3b3e-11e9-879d-005056b2844c   10Gi       RWO            Delete           Bound     molgenis-dwgqr/data-biobank-postgresql-0      nfs-provisioner-delete             14d
pvc-4a3c30b4-2f6b-11e9-879d-005056b2844c   5Gi        RWO            Delete           Bound     molgenis/data-sido-postgresql-0               nfs-provisioner-delete             30d
pvc-b7765e8e-465b-11e9-9352-005056b2844c   8Gi        RWO            Retain           Bound     molgenis-jenkins-sidos/pvc-molgenis-jenkins   nfs-provisioner-retain             20h
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
    name: molgenis-jenkins
    namespace: molgenis-jenkins
    resourceVersion: "7210898"
    uid: 4d83e691-4660-11e9-9352-005056b2844c
  ## STOP DELETE
  nfs:
    path: /molgenis-jenkins-xbxpn-molgenis-jenkins-xbxpn-pvc-b7765e8e-465b-11e9-9352-005056b2844c
    server: 192.168.64.160
  persistentVolumeReclaimPolicy: Retain
  storageClassName: nfs-provisioner-retain
  volumeMode: Filesystem
status:
  phase: Released
```

Save the changes in the ```pv.yaml```. The status should now be ```Available```

When you deleted this part you need to delete the namespace ```molgenis-jenkins```

```bash
kubectl delete namespace molgenis-jenkins
```

When you deleted the namespace you need to recreate on in the target project ```dev-molgenis``` using the rancher client.

```bash
rancher namespaces create molgenis-jenkins
```

Then import the following ```persistent volume claim``` (from now on referred as ```pvc```) to rebind the pv. 

The ```pvc.yaml``` should look like this.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: molgenis-jenkins
  namespace: molgenis-jenkins
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

Now you can enter in the Jenkins chart the ```existingClaimName```. It should now refer to the ```name``` of the ```pvc```.

>note: IMPORTANT make sure you deploy the chart in the ```molgenis-jenkins``` namespace you created. 