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
