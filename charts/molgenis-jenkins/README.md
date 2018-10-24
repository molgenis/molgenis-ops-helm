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
jenkins.Master.InstallPlugins={kubernetes:1.8.4, workflow-aggregator:2.5, workflow-job:2.21, credentials-binding:1.16, git:3.9.1, blueocean:1.6.2, github-oauth:0.29}
jenkins.Master.Security.UseGitHub=false
## if UseGitHub=true
jenkins.Master.Security.GitHub.ClientID=id
jenkins.Master.Security.GitHub.ClientSecret=S3cr3t
## end UseGitHub=true
PipelineSecrets.Env.PGPPassphrase=literal:S3cr3t
# Global git config
jenkins.Master.git.name=MOLGENIS Jenkins
jenkins.Master.git.user=molgenis+ci@gmail.com
```

You can use [all configuration values of the jenkins subchart](https://github.com/kubernetes/charts/tree/master/stable/jenkins).
> Because we use jenkins as a sub-chart, you should prefix all value keys with `jenkins`!

### GitHub Authentication delegation
You need to setup a MOLGENIS - Jenkins GitHub OAuth App. You can do this by accessing this url: [add new OAuth app](https://github.com/settings/applications/new).

### Secrets

   When deployed, the chart creates a couple of kubernetes secrets that get used by jenkins.

   You can override the values at deploy time but otherwise also configure them 
   [in Rancher](https://rancher.molgenis.org:7443/p/c-mhkqb:project-2pf45/secrets) or through kubectl.

#### Vault

The vault secret gets mounted in the vault pod so pipeline scripts can retrieve secrets from the vault.

| Parameter                 | Description                                | Default                                        |
| ------------------------- | ------------------------------------------ | ---------------------------------------------- |
| `secret.vault.token`      | Token to log into the hashicorp vault      | `xxxx`                                         |
| `secret.vault.addr`       | Address of the vault                       | `https:vault-operator.vault-operator.svc:8200` |
| `secret.vault.skipVerify` | Skip verification of the https connection  | `1`                                            |

#### GitHub

Token used by Jenkins to authenticate on GitHub.

| Parameter             | Description              | Default            |
| --------------------- | ------------------------ | ------------------ |
| `secret.gitHub.user`  | username for the account | `molgenis-jenkins` |
| `secret.gitHub.token` | token for the account    | `xxxx`             |

#### Gogs

Token used by Jenkins to authenticate on the [RuG Webhosting Gogs](https://git.webhosting.rug.nl).

| Parameter           | Description              | Default   |
| ------------------- | ------------------------ | --------- |
| `secret.gogs.user`  | username for the account | `p281392` |
| `secret.gogs.token` | token for the account    | `xxxx`    |


#### Slack
The Slack integration is done mostly in the Jenkinsfile of each project. It is sufficient to only add the plugin to the Jenkins configuration in Helm.

#### Legacy:

##### Docker Hub
   
Account used in pipeline builds to push docker images to `hub.docker.com`.
> They should read `secret/gcc/account/dockerhub` from vault instead!

| Parameter                   | Description              | Default         |
| --------------------------- | ------------------------ | --------------- |
| `secret.dockerHub.user`     | username for the account | `molgenisci`    |
| `secret.dockerHub.password` | password for the account | `xxxx`          |

##### Registry
   
Account used in pipeline builds to push docker images to `registry.molgenis.org`.
> They should read `secret/ops/account/nexus` from vault instead!

| Parameter                   | Description              | Default   |
| --------------------------- | ------------------------ | --------- |
| `secret.dockerHub.user`     | username for the account | `admin`   |
| `secret.dockerHub.password` | password for the account | `xxxx`    |

## Command line use
Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.
For example,

```bash
$ helm install --name jenkins -f values.yaml molgenis-jenkins
```

> **Tip**: You can use the default [values.yaml](values.yaml)

