# MOLGENIS - NEXUS Helm Chart
NEXUS repository for kubernetes to deploy on a kubernetes cluster with NFS-share

## Deployment
This chart will deploy:

- 1 NEXUS-nfs initialization container

  We need this container to avoid permission issues on the NEXUS docker
- 1 NEXUS container

## Plugins
On top of the default deployment of the NEXUS we added the following plugins:
- [nexus3-github-oauth-plugin](https://github.com/larscheid-schmitzhermes/nexus3-github-oauth-plugin)

## Repositories
Besides these plugins we have also amended repositories to aid our needs:
- [nexus-repository-helm](https://github.com/sonatype-nexus-community/nexus-repository-helm)
- [nexus-repository-r](https://github.com/sonatype-nexus-community/nexus-repository-r)

## Authenticate with GitHub
To configure your GitHub organisation with NEXUS please check: [nexus3-github-oauth-plugin](https://github.com/larscheid-schmitzhermes/nexus3-github-oauth-plugin) documentation.

## Upgrade the NEXUS
Make changes in the chart. Release the chart and **make sure make sure you fill in the existing volume claim**.

## Development
You can test in install the chart by executing:

```helm lint .```

To test if your helm chart-syntax is right and:

```helm install . --dry-run --debug```

To test if your hem chart works and:

```helm install .```

To deploy it on the cluster.

```curl -L -u xxxx:xxxx http://registry.molgenis.org/repository/helm/ --upload-file molgenis-x.x.x.tgz```

To push it to the registry

## Troubleshooting
Please check: [troubleshooting guide](TROUBLESHOOTING.md)
