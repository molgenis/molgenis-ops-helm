# KES server

The KES server is used by MinIO to encrypt encryption keys for the objects it stores. These keys are encrypted using a master encryption key that is stored in HashiCorp Vault.

For more background check [the KES documentation](https://github.com/minio/kes/wiki/Concepts).

# Overview of the deployment
![Architecture](https://raw.githubusercontent.com/minio/kes/master/.github/arch.png)

## The KMS (vault chart)
There is one single KMS: https://vault.molgenis.org. It runs on the prod cluster. The KES servers on a different cluster can access the vault on a node port.

## The KES Server (this chart)
The KES Server is stateless, it stores the applications' root keys in the vault's `secret` engine.
All KES deployments use the same vault so each KES deployment has its own path on the vault. E.g. path `kes/dev` is used by the `dev` KES Server deployment. A deployment can scale to multiple replica's, since it is stateless.

The applications communicate with the KES Server using mutual  TLS (mTLS). This chart generates a private key and a self-signed public certificate when it is first deployed.
The certificate has two DNS entries, one for `<service name>.<namespace>` and one for `<service name>.<namespace>.svc`
## The Applications (MinIO subchart)
Each MinIO instance authenticates with the KES Server using a unique client private key and public certificate that is generated when it is deployed.

Each MinIO deployment has its own master encryption key that it uses to encrypt the objects. So the master encryption key for MinIO deployment `gecko` on KES Server `accept` is stored in the vault as `/secret/kes/accept/gecko`.

# Configuration
## Vault
To give the `dev` KES deployment permissions on the vault, we create in the vault
* a policy `kes-dev` that grants `create`, `read` and `list` permissions on the `secret/kes/dev/*` path
* App role `kes-dev` with a role ID and a secret ID that grants the permissions from the `kes-dev` policy.

For more background on app roles, HashiCorp has an [AppRole Pull Authentication tutorial](https://learn.hashicorp.com/tutorials/vault/approle).
![AppRole workflow](https://learn.hashicorp.com/img/vault-approle-workflow.png)

### Create the policy

You need to be logged in on the vault using a token that can manage policies.
The `kes-dev` policy is
```
path "secret/kes/dev/*" {
  capabilities = ["read", "create", "list"]
}
```
You can create the policy in the Vault UI.

### Create the AppRole
To create the `kes-dev` AppRole you can use the Browser CLI in the top of the Vault UI.

```
> vault write auth/approle/role/kes-dev token_policies="default,kes-dev" period=24h
```

### Retrieve the AppRole role ID
```
> vault read auth/approle/role/kes-dev/role-id
```

### Create an AppRole secret ID
You can only read the secret ID when you create it. If you lose it you must create a new one.
```
> vault write -force auth/approle/role/kes-dev/secret-id
```

## MinIO
To configure a MinIO deployment you need to [install the `kes` command line tool](https://github.com/minio/kes#install).

### Specify KES Server certificate
MinIO needs to trust the self-signed KES Server certificate, so it must be added to the trusted CA certificate directory.
The MinIO chart needs to be version 7.2.1 or higher to be able to mount CA keys from an external secret.

In the Armadillo chart, there's a question where you can fill in the KES Server certificate. The KES-certificate can be found in the secrets of the KES server.

### Decide on master encryption key name
The armadillo chart asks for the master encryption key name when you deploy it.

### Determine identity of MinIO Client certificate
When you deploy the chart, it generates a TLS client certificate and private key. The KES server policy grants permissions to the client based on the identity of the client certificate. If you copy the client certificate to a local file `client.cert`, you can compute its identity using

```
> kes tool identity of client.cert
```

### Add policy to KES server
Then you add a policy fragment to the KES Server deployment, granting the MinIO client permissions on the master encryption key:
```
<keyname>:
  paths:
    - /v1/key/create/<keyname>*
    - /v1/key/generate/<keyname>*
    - /v1/key/decrypt/<keyname>*
  identities:
    - <identity of MinIO client certificate>
```
And restart the KES pods.

### Create Master encryption key on the KES server

To create the key, you need to
* port-forward a kes pod's 7373 port to localhost (This is nontrivial to set up, but out of the scope of this document. Use `rancher kubectl port-forward` or if `kubectl` works you can use `k9s`)
* download the trusted `client.key` and `client.cert`, created by the MinIO deployment
* set the CLI env vars
```
> export KES_CLIENT_KEY=./client.key
> export KES_CLIENT_CERT=./client.cert
```
* generate the master encryption key
```
> kes key create -k <keyname>
```

## When a KES Server certificate expires
The KES Server certificate is valid for 365 days. When it expires you can simply delete and redeploy the kes server, since it is stateless.
* Copy the KES Server policy before you delete it, as it contains the identities of the Application client certificates.
* When the KES Server is redeployed, a new certificate is generated. You need to fill it in in the MinIO deployments.

## When a MinIO client certificate expires
The MinIO deployments are not stateless. It is probably easiest to generate a new certificate by hand and fill it in in the config map. Restart the MinIO pods. Make sure to update the identity in the KES Server policy.
