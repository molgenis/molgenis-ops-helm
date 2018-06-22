# MOLGENIS Helm templates


## Useful commands for Kubernetes

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

## Useful commands for Helm

- helm install .
  Do it in the root of the project where the Chart.yaml is located
  It installs a release of a kubernetes stack. You also store this as an artifact in a kubernetes repository
- helm list
  Lists all installed releases
- helm delete #release#
  Performs a sort of mvn clean on your workspace. Very handy for zombie persistent volumes or claims.