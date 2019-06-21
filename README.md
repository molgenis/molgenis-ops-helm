# test MOLGENIS - Helm templates

These are the Helm templates that we will use for MOLGENIS operations. Basic concepts in respect to docker you need to know.

**Deployments**

Are a set of pods that will be deployed according to configuration that is usually managed bij Helm. These pods interact with eachother by being in the same namespace created by kubernetes according to the deployment configuration. 

**Pods**

A pod is wrapper around a container. It will recreate the container when it is shutdown for some reason and interact with other pods when needed.

**Containers**

A container is a docker-container that is created from a docker image. It could be seen as an VM for example

**Images**

An image is a template for a container some sort of boot script but also contains the os for example. A build dockerfile, if you will.

**Prerequisites**

There are some prerequisites you need.

- docker
- minikube
 
## Kubernetes

When you want to use kubernetes there are some commands you need to know. Also running on a remote cluster will be a must have to control your whole DTAP.

### Useful commands

Commands that can be used to get information from a kubernetes cluster

**Pods**

- ```kubectl get pods (optional: [--all-namspaces])```
  
  Gets alls running instances of containers from a certain deployment

- ```kubectl describe pod #pod name# --namespace=#namesspace#```

  Describes the pod initialization, also displays error messages more accurately if they occur

**Services**

- ```kubectl get services```

  Gets all services from a deployment

**Volumes**
  
- ```kubectl get pv```
  
  Gets all persistant volumes
- ```kubectl get pvc```
  
  Gets all persistent volume claims

**Deployments**

- ```kubectl get deployments```
  
  Gets all deployments (comparable with docker-compose)
    

## Remote clusters

When you want to see what is running on the clusters at the CIT you have to make a context switch.
You can access the cluster with kubeconfig-files. You can obtain these by downloading them from the 
MOLGENIS kubernetes cluster.

- Go to https://rancher.molgenis.org:7777 and login
- Go to Rancher --> Cluster: *#name#* --> *Kubeconfig File*
- Go to a **Terminal** where ```kubectl``` is available
- Add this configuration to ~/.kube/config (or place a new file besides this one)
  
  *Example*: 
```bash
# When you added the MOLGENIS configuration to the original configuration
kubectl config use-context molgenis

# or when you placed the MOLGENIS configuration besides the original one
kubectl config use-context molgenis --kubeconfig=*full path to molgenis config*
```
- You can now access all facilities of the MOLGENIS cluster like it is running locally
  
  *Example:*
```bash
kubectl get pods --namespace=*#namespace of application#*
```

## Helm

This repository is serves also as a catalogue for Rancher. We have serveral apps that are served through this repoistory. e.g.

- [Jenkins](charts/molgenis-jenkins/README.md)
- [NEXUS](charts/molgenis-nexus/README.md)
- [Vault](charts/molgenis-vault/README.md)
- [Sentry](charts/molgenis-sentry/README.md)
- [MOLGENIS](charts/molgenis/README.md)
- [Elasticsearch](charts/molgenis-elasticsearch/README.md)
- [OpenCPU](charts/molgenis-opencpu/README.md)
- [Hubot](chart/molgenis-hubot/README.md)

### Useful commands
You can you need to know to easily develop and deploy helm-charts

- ```helm lint .```

  To test your helm chart for code errors.

- ```helm install . --dry-run --debug```

  Check if your configuration deploys on a kubernetes cluster and check the configuration

- ```helm install . #release name# --namespace #remote namespace#```
  
  Do it in the root of the project where the Chart.yaml is located
  It installs a release of a kubernetes stack. You also store this as an artifact in a kubernetes repository
- ```helm package .```
  
  You can create a package which can be uploaded in the molgenis helm repository
  
- ```helm publish```
  You still have to create an ```index.yaml``` for the chart. You can do this by executing this command: ```helm repo index #directory name of helm chart#```
  
  Then you can upload it by executing:
  
  - ```curl -v --user #username#:#password# --upload-file index.yaml  https://registry.molgenis.org/repository/helm/#chart name#/index.yml```
  - ```curl -v --user #username#:#password# --upload-file #chart name#-#version#.tgz https://registry.molgenis.org/repository/helm/#chart name#/#chart name#-#version#.tgz```
  
  Now you have to add the repository locally to use in your ```requirements.yaml```.
  
  - ```helm repo add #repository name# https://registry.molgenis.org/repository/helm/molgenis```

- ```helm dep build```
  
  You can build your dependencies (create a ```charts``` directory and install the chart in it) of the helm-chart. 

- ```helm list```
  
  Lists all installed releases
- ```helm delete #release#```
  
  Performs a sort of mvn clean on your workspace. Very handy for zombie persistent volumes or claims.

- ```install tiller on remote cluster```

  To install tiller on a remote cluster you need an rbac-config.yml.
  ```kubectl create -f rbac-config.yaml```

  When you have defined the yaml you can add the tiller to the cluster by following the steps below.
  ```helm init --service-account tiller```  

## Persistence
The manage your pv's you have to make a distinction between retainable pv's and non-retainable pv's.

- retain: keep forever
- non-retain: throw away when deployment is deleted

The status "released" is the keyword that the volume is not attached to a deployment anymore.  
  
### Cleanup old pv's

Fetch all released pv's to check if they are all released.

```bash
kubectl get pv | grep Released
```  

Then remove them permanently.

```bash
kubectl get pv | grep Released | grep -o '^\S*' | grep . | xargs kubectl delete pv
```

## Orphaned kubernetes resources
You can terminate orphaned resources can be a pain. We described how to deal with 2 of them.

### Pods
Sometimes pods won't die on themselves and you need to help them a little.

```kubectl remove pod #pod name# --namespace=#namespace# (optional: [--force] [--grace-period=0])```

Removes a pod from the system (but will restart if the option is set in the deployment,yaml *[see note]*). 
  
>note: You can not do this while the deployment of the service is still there

### Namespaces
To permanently terminate the namespace you have to catch the JSON output in a file.

```
kubectl get namespace molgenis-sentry -o=json > sentry.json
```

Then you need delete some parts of the namespace JSON to purge the repo.

```json
{
    "apiVersion": "v1",
    "kind": "Namespace",
    "metadata": {
        "annotations": {
            "cattle.io/appIds": "molgenis-sentry",
            "cattle.io/status": "{\"Conditions\":[{\"Type\":\"InitialRolesPopulated\",\"Status\":\"True\",\"Message\":\"\",\"LastUpdateTime\":\"2018-12-17T15:08:28Z\"},{\"Type\":\"ResourceQuotaInit\",\"St
            "field.cattle.io/creatorId": "u-6nb8b",
            "field.cattle.io/projectId": "c-rrz2w:p-fsjx8",
            "lifecycle.cattle.io/create.namespace-auth": "true"
        },
        "creationTimestamp": "2018-12-17T15:08:58Z",
        "finalizers": [
            "controller.cattle.io/namespace-auth"
        ],
        "labels": {
            "cattle.io/creator": "norman",
            "field.cattle.io/projectId": "p-fsjx8"
        },
        "name": "molgenis-sentry",
        
        // START DELETE
        "resourceVersion": "21694313",
        // END DELETE
        
        "selfLink": "/api/v1/namespaces/molgenis-sentry",
        "uid": "add523b7-020d-11e9-ac6d-005056b29ae4"
    },
   
    // START DELETE 
    "spec": {
        "finalizers": [
            "kubernetes"
        ]
    },
    // END DELETE
    
    "status": {
        "phase": "Active"
    }
}
```

Then when you determined the cluster name with ```rancher cluster``` you can enter it where *#cluster#* stands and you can fill the target namespace where #target-namespace# stands.
Execute the curl.

```bash
curl -k -H "Content-Type: application/json" -X PUT --data-binary @sentry.json http://127.0.0.1:8001/k8s/clusters/#cluster#/api/v1/namespaces/#target-namespace#/finalize
``` 

This should be the result:

```json
{
  "kind": "Namespace",
  "apiVersion": "v1",
  "metadata": {
    "name": "molgenis-sentry",
    "selfLink": "/api/v1/namespaces/molgenis-sentry/finalize",
    "uid": "e48cb533-01dd-11e9-ac6d-005056b29ae4",
    "resourceVersion": "21692263",
    "creationTimestamp": "2018-12-17T09:26:54Z",
    "deletionTimestamp": "2018-12-17T09:50:01Z",
    "labels": {
      "cattle.io/creator": "norman",
      "field.cattle.io/projectId": "p-fsjx8"
    },
    "annotations": {
      "cattle.io/status": "{\"Conditions\":[{\"Type\":\"InitialRolesPopulated\",\"Status\":\"True\",\"Message\":\"\",\"LastUpdateTime\":\"2018-12-17T09:26:24Z\"},{\"Type\":\"ResourceQuotaInit\",\"Status\":\"True\",\"Message\":\"\",\"LastUpdateTime\":\"2018-12-17T09:26:23Z\"}]}",
      "field.cattle.io/creatorId": "u-6nb8b",
      "field.cattle.io/projectId": "c-rrz2w:p-fsjx8",
      "lifecycle.cattle.io/create.namespace-auth": "true"
    }
  },
  "spec": {
    
  },
  "status": {
    "phase": "Terminating"
  }
}%                                
```
