# MOLGENIS - Website Helm Chart

Website Helm chart to deploy the molgenis.org website.

## Containers

This chart will deploy the following containers:

- NGINX

## Provisioning
You can choose which version of the NGINX image you want to deploy. Each merge with the master results in a tagged image with the build-number.  
You need to fill out 2 properties to determine which repository you are going to use.

- ```site.image.repository```
- ```site.image.tag```

You can do this in the questions in Rancher or in the ```values.yaml```.

## Development
You can test in install the chart by executing:

```helm lint .```

To test if your helm chart-syntax is right and:

```helm install . --dry-run --debug```

To test if your hem chart works and:

```helm install .```

To deploy it on the cluster.


