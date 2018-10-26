# Firewall

https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/configmap.md

```bash
# install kubectx and kubens
brew install kubectx

# list all configured clusters
kubectx

# molgenis-prod
# molgenis-dev

# switch to molgenis-prod cluster
kubectx molgenis-prod

# list all namespaces
kubens

# kube-system
# molgenis-rdconnect
# molgenis-solverd

# switch to kube-system
kubens kube-system

kubectl create -f firewall-umcg.yaml


```