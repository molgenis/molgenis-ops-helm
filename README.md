# MOLGENIS Helm templates

These are the Helm templates that we will use for MOLGENIS operations. There are some prerequisites you need.

- docker
- minikube
 
## Useful commands for Kubernetes

Commands that can be used to get information from a kubernetes cluster

- kubectl get pods
  Gets alls running instances of containers from a certain deployment
- kubectl get services
  Gets all services from a deployment
- kubectl get pv
  Gets all persistant volumes
- kubectl get pvc
  Gets all persistent volume claims
- kubectl get deployments
  Gets all deployments (comparable with docker-compose)

When you want to see what is running on the clusters at the CIT you have to make a context switch.
You can access the cluster with kubeconfig-files. You can obtain these by downloading them from the 
MOLGENIS kubernetes cluster.

- Goto https://rancher.molgenis.org:7443
- Goto 


## Useful commands for Helm

- helm install .
  Do it in the root of the project where the Chart.yaml is located
  It installs a release of a kubernetes stack. You also store this as an artifact in a kubernetes repository
- helm list
  Lists all installed releases
- helm delete #release#
  Performs a sort of mvn clean on your workspace. Very handy for zombie persistent volumes or claims.