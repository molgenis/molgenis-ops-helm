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

# Access
Access the vault locally by port forwarding the service. You need to do this when you want to use the commandline interface of vault.

```bash
kubens

molgenis-jenkins
molgenis-hubot
...
vault-operator (or somehting similar)

kubens vault-operator
kubectl get pods

etcd-operator-#hash#
...
vault-#hash#

kubectl port-forward vault-#hash# 8200:8200
```

Make sure you have the variable below in your environment. This enabled you to access the pod locally.

```bash
export VAULT_SKIP_VERIFY=1
```


## Unseal the vault
If the vault is sealed you can unseal it by executing the command below 3 times. Each time you need to fill in a unsealing key which is provided when you initialize the vault.

```bash
vault operator unseal

Unseal Key (will be hidden): 

Key                Value
---                -----
Seal Type          shamir
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       xxxx
Version            0.9.1
HA Enabled         true
```

## Create new token
A new token is needed when the old one expires. In Jenkins we use a buildsecret reader token. This tokens expires once a month unfortunatly. You can create a new one with the command below.

```bash
vault token create -policy=buildsecret-reader

Key                  Value
---                  -----
token                xxxx
token_accessor       xxxx
token_duration       768h
token_renewable      true
token_policies       []
identity_policies    []
policies             ["buildsecret-reader" "default"]
```

### Add it to Jenkins
When you want to make it available in Jenkins you need to go to [rancher](https://rancher.molgenis.org:7777). 
Here you want to access the secrets of the right project. In our case you need to perform the following steps:
- Goto *Clusters --> Projects --> Development*
- Goto *Resources --> Secrets*
- Edit *molgenis-pipeline-vault-secret*
- Add the new token