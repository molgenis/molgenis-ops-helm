#!/bin/sh
command="cd /data && ct lint --config ct.yaml --all"

docker run -it --rm --name ct --volume $(pwd):/data quay.io/helmpack/chart-testing:v3.3.1 sh -c "${command}"