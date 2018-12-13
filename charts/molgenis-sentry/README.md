# Molgenis Sentry Helm Chart

Wraps [the kuberenetes sentry chart](https://github.com/kubernetes/charts/tree/master/stable/sentry), see documentation there!

## Chart Details

This chart will do the following:

- a Sentry instance
- a PostgreSQL instance as backend
- some operators for backup recovery

## Installing the Chart

Usually, you'll be deploying this to the molgenis cluster.
In the [Rancher Catalog](https://rancher.molgenis.org:7443/g/catalog), add the latest version of this repository.
In the [molgenis cluster management page](https://rancher.molgenis.org:7443/p/c-mhkqb:project-2pf45/apps), choose the 
catalog, pick the molgenis-sentry app from the catalog and deploy it.

## Configuration
When deploying, you can paste values into the Rancher Answers to override the defaults in this chart.
Array values can be added as {value, value, value}.
```
ingress.enabled=true
ingress.hostname=sentry.dev.molgenis.org

persistence.enabled=false

email.host=smtp.example.org
email.user=postman
email.passwordxxxxx

service.type=ClusterIP

postgresql.persistence.enabled=false
```

You can use [all configuration values of the sentry subchart](https://github.com/kubernetes/charts/tree/master/stable/sentry).
> Because we use jenkins as a sub-chart, you should prefix all value keys with `sentry`!

### User configuration
Delegate to github with the following image. You need to install the plugin: [oauth github](https://github.com/getsentry/sentry-auth-github).

Then you need to specify the GITHUB_APP_ID and GITHUB_API_SECRET in the ```questions.yml``` or via the helm cli: ```helm install . --set "sentry.web.env[0].name=GITHUB_APP_ID,sentry.web.env[0].value=xxx,sentry.web.env[1].name=GITHUB_API_SECRET,sentry.web.env[1].value=xxx"``` .

## Add new project keys to the MOLGENIS instances
Follow the *Sentry* steps below to acquire the key:

- Goto https://sentry.molgenis.org
- Login
- Goto the project referring to your server (*master-dev-molgenis-org*)
- Goto *Settings*
- Goto *Client Keys (DSN)* (on the left-side of the screen)
- Copy the key (example: https://32895egiuwhnglkjbf9730y9tb@sentry.molgenis.org/1)

Target system steps:

Docker
- Goto https://rancher.molgenis.org:7777
- Upgrade the target MOLGENIS instance
- Add the following *answer* to the upgrade by clicking on *Edit Yaml*
- ```sentry.molgenis.dsn


## Command line use
Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.
For example,

```bash
$ helm install --name sentry -f values.yaml molgenis-sentry
```

> **Tip**: You can use the default [values.yaml](values.yaml)

