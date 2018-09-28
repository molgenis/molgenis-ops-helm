# MOLGENIS Vault helm chart

This chart creates a vault operator, but NO vault.
The vault operator defines a new custom resource named `vault` that you can use to create vaults.

After launching the operator, create the molgenis vault manually:
`kubectl create -f resources/vault.yaml`

That creates a new vault with two vault pods.

See https://github.com/coreos/vault-operator/blob/master/doc/user/vault.md

## Parameters

### Azure cloud credentials
Define credentials for backup to the Azure Blob Store.
See [etcd-operator documentation](https://github.com/coreos/etcd-operator/blob/master/doc/user/abs_backup.md).

| Parameter       | Description                   | Default            |
| --------------- | ----------------------------- | ------------------ |
| `abs.account`   | name of storage account       | `fdlkops`          |
| `abs.accessKey` | access key of storage account | `xxxx`             |
| `abs.cloud`     | name of cloud environment     | `AzurePublicCloud` |

### Backup job
Define the schedule of the backup job

| Parameter            | Description                  | Default       |
| -------------------- | ---------------------------- | ------------- |
| `backupJob.enable`   | Enable backup cronjob        | `true`        |
| `backupJob.schedule` | cron schedule for the backup | `0 12 * * 1`  |

### UI

Parameter | Description | Default
--------- | ----------- | ------- 
`ui.replicaCount` | desired number of Vault UI pod | `1`
`ui.image.repository` | Vault UI container image repository | `djenriquez/vault-ui`
`ui.image.tag` | Vault UI container image tag | `latest`
`ui.resources` | Vault UI pod resource requests & limits | `{}`
`ui.nodeSelector` | node labels for Vault UI pod assignment | `{deployPod: "true"}`
`ui.ingress.enabled` | If true, Vault UI Ingress will be created | `true`
`ui.ingress.annotations` | Vault UI Ingress annotations | `{}`
`ui.ingress.host` | Vault UI Ingress hostname | `vault.molgenis.org`
`ui.ingress.tls` | Vault UI Ingress TLS configuration (YAML) | `[]`
`ui.vault.url` | Vault UI default vault url | `https://vault.vault-operator:8200`
`ui.vault.auth` | Vault UI login method | `GITHUB`
`ui.service.name` | Vault UI service name | `vault-ui`
`ui.service.type` | type of ui service to create | `ClusterIP`
`ui.service.externalPort` | Vault UI service target port | `8000`
`ui.service.internalPort` | Vault UI container port | `8000`
`ui.service.nodePort` | Port to be used as the service NodePort (ignored if `server.service.type` is not `NodePort`) | `0`