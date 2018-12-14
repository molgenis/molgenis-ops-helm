# Molgenis Sentry Helm Chart

Wraps [the kuberenetes sentry chart](https://github.com/kubernetes/charts/tree/master/stable/sentry), see documentation there!

## Chart Details

This chart will do the following:

- a Sentry instance
- a PostgreSQL instance as backend
- a Redis instance for configuration

## Installing the Chart

Usually, you'll be deploying this to the molgenis cluster.
In the [Rancher Catalog](https://rancher.molgenis.org:7777/g/catalog), add the latest version of this repository.
In the [molgenis cluster management page](https://rancher.molgenis.org:7777/p/c-rrz2w:p-fsjx8/apps), choose the 
catalog, pick the molgenis-sentry app from the catalog and deploy it.

## Configuration
When deploying, you can paste values into the Rancher Answers to override the defaults in this chart.
Array values can be added as {value, value, value}.
```
ingress.enabled=true
ingress.hostname=sentry.molgenis.org

user.email=sentry@molgenis.org

email.host=smtp.rug.nl
email.user=
email.password=

service.type=ClusterIP

persistence.enabled=false

postgresql.persistence.enabled=false

redis.master.persistence.enabled=false
```

You can use [all configuration values of the sentry subchart](https://github.com/kubernetes/charts/tree/master/stable/sentry).
> Because we use sentry as a sub-chart, you should prefix all value keys with `sentry`!

### User configuration 
When you first login into Sentry you need to use the ```user.email``` given in the ```values.yaml```. You can get the generated secrets from the kubernetes secrets in Rancher to obtain the password (the key is ```user-secret```).
You need to configure in the ```values.yaml``` our own Sentry image (```molgenis/sentry:9.0```).

When you want to delegate the authentication to github, you need to use the image below.

```yaml
sentry:
  image:
    repository: molgenis/sentry
    tag: 9.0 
``` 

Then you need to specify the GITHUB_APP_ID and GITHUB_API_SECRET in the ```questions.yml``` or via the helm cli: ```helm install . --set "sentry.web.env[0].name=GITHUB_APP_ID,sentry.web.env[0].value=xxx,sentry.web.env[1].name=GITHUB_API_SECRET,sentry.web.env[1].value=xxx"``` .

#### Install an new OAuth application
Last but not least you need to configure a new OAuth application on the Github MOLGENIS organisation.
Please copy the APP_ID and API_SECRET to a place where you can find them.

Configure the **Authorization callback URL** to: https://sentry.molgenis.org/

#### Configure the Github Authentication Delegation in Sentry
> note: Make sure you are logged in as the 'molgenis-jenkins' user in Github. This way you attach the admin user in sentry to this account.
        
You need to follow the steps below.

- Goto the https://sentry.molgenis.org
- Goto the *Sentry organisation* (MOLGENIS for example)
- Goto **Auth** (on the leftside of the screen)
- Click on *Configure Github*

## Add new Sentry-Client-DSN keys to the MOLGENIS instances
Follow the *Sentry* steps below to acquire the key:

- Goto https://sentry.molgenis.org
- Login
- Goto the project referring to your server (*master-dev-molgenis-org*)
- Goto *Settings*
- Goto *Client Keys (DSN)* (on the left-side of the screen)
- Copy the key (example: https://32895egiuwhnglkjbf9730y9tb@sentry.molgenis.org/1)

Target system steps:

**Docker**
- Goto https://rancher.molgenis.org:7777
- Upgrade the target MOLGENIS instance
- Add the following *answer* to the upgrade by clicking on *Edit Yaml*
- ```sentry.molgenis.dsn=xxxx```
- Click on *Upgrade*

**Virtual machine - CentOS 6.10**
Add the following environment variable in the MOLGENIS user profile (```~/.bashrc```).

```export SENTRY_DSN=xxxx``` ( https://{public key}@sentry.molgenis.org/{project id} )
```export SENTRY_RELEASE=7.4.1``` ( x.x.x )
```export SENTRY_SERVERNAME=molgenis01.gcc.rug.nl``` ( sub.example.org )

Restart TOMCAT

```service tomcat restart```

## Command line use
Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.
For example,

```bash
$ helm install --name sentry -f values.yaml molgenis-sentry
```

> **Tip**: You can use the default [values.yaml](values.yaml)

