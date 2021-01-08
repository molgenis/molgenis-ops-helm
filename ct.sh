#!/bin/sh
command="cd /data && helm init --client-only --stable-repo-url https://charts.helm.sh/stable && "
command+="helm repo add molgenis https://helm.molgenis.org && "
command+="helm repo add molgenis-helm https://registry.molgenis.org/repository/helm && "
command+="helm repo add elastic https://helm.elastic.co/ && "
command+="helm repo add fusionauth https://fusionauth.github.io/charts && "
command+="helm repo add bitnami https://charts.bitnami.com/bitnami && "
command+="helm repo add jenkins https://charts.jenkins.io && "
command+="helm repo add minio https://helm.min.io/ && "
command+="ct lint"

docker run -it --rm --name ct --volume $(pwd):/data quay.io/helmpack/chart-testing:v2.2.0 sh -c "${command}"