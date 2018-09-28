# Helm in Jenkins

To be able to run helm inside a jenkins pod, you'll need to 
* create a role in the namespace where tiller is installed
* bind that role to the user that jenkins pods run as

This directory contains yaml for these resources.
See also https://github.com/helm/helm/blob/master/docs/rbac.md