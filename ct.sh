#!/bin/sh
command="cd /data && helm init --client-only --stable-repo-url https://charts.helm.sh/stable && ct lint --config ct.yaml --all"

docker run -it --rm --name ct --volume $(pwd):/data quay.io/helmpack/chart-testing:v2.2.0 sh -c "${command}"