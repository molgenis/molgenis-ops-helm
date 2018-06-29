# Molgenis Jenkins Helm Chart

Jenkins master and slave cluster utilizing the Jenkins Kubernetes plugin.
Wraps [the kuberenetes jenkins chart](https://github.com/kubernetes/charts/tree/master/stable/jenkins), see documentation there!

## Chart Details

This chart will do the following:

* 1 x Jenkins Master with port 8080 exposed on an external ClusterIP
* All using Kubernetes Deployments

## Installing the Chart

Usually, you'll be deploying this to the molgenis cluster.
In the [Rancher Catalog](https://rancher.molgenis.org:7443/g/catalog), add the latest version of this repository.
In the [molgenis cluster management page](https://rancher.molgenis.org:7443/p/c-mhkqb:project-2pf45/apps), choose the 
catalog, pick the molgenis-jenkins app from the catalog and deploy it.

## Configuration

When deploying, you can paste values into the Rancher Answers to override the defaults in this chart.
Array values can be added as {value, value, value}.
```
jenkins.Master.HostName=jenkins.molgenis.org
jenkins.Master.AdminPassword=pa$$word
jenkins.Persistence.Enabled=false
jenkins.Master.InstallPlugins={kubernetes:1.8.4, workflow-aggregator:2.5, workflow-job:2.21, credentials-binding:1.16, git:3.9.1}
PipelineSecrets.Env.PGPPassphrase=literal:S3cr3t
```

You can use [all configuration values of the jenkins subchart](https://github.com/kubernetes/charts/tree/master/stable/jenkins).
> Because we use jenkins as a sub-chart, you should prefix all value keys with `jenkins`!

There is one additional group of configuration items specific for this chart, so not prefixed with `jenkins`:
## PipelineSecrets

When deployed, the chart creates a couple of kubernetes secrets that get used by jenkins and mounted in the jenkins 
build pods. The secrets, like the rest of the deployment, is namespaced so multiple instances can run beside
each other with their own secrets.

You can override the values at deploy time but otherwise also configure them 
[in Rancher](https://rancher.molgenis.org:7443/p/c-mhkqb:project-2pf45/secrets) or through kubectl.

### Env
Environment variables stored in molgenis-pipeline-env secret, to be added as environment variables
in the slave pods.

| Parameter                          | Description                          | Default         |
| ---------------------------------- | ------------------------------------ | --------------- |
| `PipelineSecrets.Env.Replace`      | Replace molgenis-pipeline-env secret | `true`          |
| `PipelineSecrets.Env.PGPPassphrase`| passphrase for the pgp signing key   | `literal:xxxx`  |
| `PipelineSecrets.Env.CodecovToken` | token for codecov.io                 | `xxxx`          |
| `PipelineSecrets.Env.GithubToken`  | token for GH molgenis-jenkins user   | `xxxx`          |
| `PipelineSecrets.Env.SonarToken`   | token for sonarcloud.io              | `xxxx`          |                                                            |

### File

Environment variables stored in molgenis-pipeline-file secret, to be mounted as files
in the `/root/.m2` directory of the slave pods.
> The settings.xml file references the 

| Parameter                              | Description                           | Default                                                                         |
| -------------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------- |
| `PipelineSecrets.File.Replace`         | Replace molgenis-pipeline-file secret | `true`                                                                          |
| `PipelineSecrets.File.PGPPrivateKeyAsc`| pgp signing key in ascii form         | `-----BEGIN PGP PRIVATE KEY BLOCK-----xxxxx-----END PGP PRIVATE KEY BLOCK-----` |
| `PipelineSecrets.File.MavenSettingsXML`| Maven settings.xml file               | `<settings>[...]</settings>` (see actual [values.yaml](values.yaml))            |


## Command line use
Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.
For example,

```bash
$ helm install --name jenkins -f values.yaml molgenis-jenkins
```

> **Tip**: You can use the default [values.yaml](values.yaml)

