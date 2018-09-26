# MOLGENIS - OpenCPU Helm Chart

NEXUS repository for kubernetes to deploy on a kubernetes cluster with NFS-share

## Containers

This chart will deploy the following containers:

- OpenCPU
- MOLGENIS-httpd (to proxy the registry and docker to one domain)

## Provisioning
You can choose for the OpenCPU image from which repository you want to pull. Experimental builds are pushed to registry.molgenis.org and the stable builds to hub.docker.com. 
You need to fill out 2 properties to determine which repository you are going to use.

- ```opencpu.image.repository```
- ```opencpu.image.tag```

You can do this in the questions in Rancher or in the ```values.yaml```.



## Development
You can test in install the chart by executing:

```helm lint .```

To test if your helm chart-syntax is right and:

```helm install . --dry-run --debug```

To test if your hem chart works and:

```helm install .```

To deploy it on the cluster.


