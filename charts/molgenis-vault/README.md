# MOLGENIS Vault helm chart

This chart creates a vault operator, but NO vault.

## Deploy
The deployment of the Vault consists of 9 steps.

**In Rancher**
1. Delete molgenis-vault app in prod
2. Deploy molgenis-vault in prod to the vault-operator namespace

**On your own machine**
*Context == prod-molgenis*
4. Create Vault service
   ```rancher kubectl create -f resources/vault.yaml --namespace vault-operator```
   See https://github.com/coreos/vault-operator/blob/master/doc/user/vault.md
5. Create a NodePort service on top of the Vault service
   ```rancher kubectl create -f resources/vault-nodeport.yaml --namespace vault-operator```
6. Fill in the filename of the Minio backup ```backup-move-to-minio``` in ```restore.yaml```
   ```rancher kubectl create -f resources/restore.yaml --namespace vault-operator```
7. Unlock the Vault
   ```rancher kubectl describe vault vault --namespace vault-operator```
   ```rancher kubectl port-forward #vault-pod# 8200 --namespace vault-operator```
   Install Vault client: https://www.vaultproject.io/docs/install/

**In Jenkins**
8. The NodePort is random so you need to configure it in the Kubernetes secret: ```molgenis-pipeline-vault-secret``` with key ```addr```. E.g. 'https://192.168.64.161:30221'.
   (Go to the ```prod-molgenis``` project and select **Resources** --> **Secrets**).

## Parameters

### Minio credentials
Define credentials for backup to the Azure Blob Store.
See [etcd-operator documentation](https://github.com/coreos/etcd-operator/blob/master/doc/user/abs_backup.md).

| Parameter       | Description                   | Default            |
| --------------- | ----------------------------- | ------------------ |
| `abs.account`   | name of storage account       | `xxxx`             |
| `abs.accessKey` | access key of storage account | `xxxx`             |
| `abs.cloud`     | name of cloud environment     | `Minio`            |

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
`ui.nodeSelector` | node labels for Vault UI pod assignment | `{}`
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


