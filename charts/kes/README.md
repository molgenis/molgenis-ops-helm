# KES server

The KES server is used by MinIO to generate encryption keys for the objects it stores. These keys are derived from a root key that is stored in HashiCorp Vault.

# Overview of the deployment
![Architecture](https://raw.githubusercontent.com/minio/kes/master/.github/arch.png)

## The KMS (vault chart)
There is one single KMS: https://vault.molgenis.org. It runs on the prod cluster. The KES servers on a different cluster can access the vault on a node port.

## The KES Server (this chart)
The KES Server is stateless, it stores the applications' root keys in the vault's `secret` engine.
All KES deployments use the same vault so each KES deployment has its own path on the vault. E.g. path `kes/dev` is used by the `dev` KES Server deployment. A deployment can scale to multiple replica's, since it is stateless.

The KES Server requires TLS. This chart generates a private key and a self-signed public certificate when it is first deployed.
The certificate has two DNS entries, one for `<service name>.<namespace>` and one for `<service name>.<namespace>.svc`
## The Applications (MinIO subchart)
MinIO accesses the KES Server using https.
Each MinIO instance authenticates with the KES Server using a unique client private key and public certificate that is generated when it is deployed.

Each MinIO deployment has its own root key that it uses to encrypt the objects. So the root key for MinIO deployment `gecko` on KES Server `accept` is stored in the vault as `/secret/kes/accept/gecko`.

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
To configure a MinIO deployment you need to [install the `kes` tool](https://github.com/minio/kes#install).

### KES Server certificate
MinIO needs to trust the self-signed KES Server certificate, so it must be added to the trusted CA certificate directory.
The MinIO chart needs to be version 7.2.1 or higher to be able to mount CA keys from an external secret.

In the Armadillo chart, there's a question where you can fill in the KES Server certificate.

### MinIO Client certificate
When you deploy the chart, it generates a TLS client certificate and private key. The KES server needs to know the identity of the client certificate. You can generate this using the KES client.
If you copy the client certificate to a local file `client.cert`, you can compute its identity using

```
> kes tool identity of client.cert
```

Then create a policy in the KES Server deployment and restart the KES pods.
### Root key
Each MinIO deployment needs its own key. The armadillo chart asks for the root key name when you deploy it.

To create the key, you need to
* port-forward a kes pod's 7373 port to localhost (This is nontrivial to set up, but out of the scope of this document. Use `rancher kubectl port-forward` or if `kubectl` works you can use `k9s`)
* download a trusted `client.key` and `client.cert`, for example those created by the MinIO deployment
* set the CLI env vars
```
> export KES_CLIENT_KEY=./client.key
> export KES_CLIENT_CERT=./client.cert
```
* generate the key
```
> kes key create -k gecko
```

## When a KES Server certificate expires
The KES Server certificate is valid for 365 days. When it expires you can simply delete and redeploy the kes server, since it is stateless.
* Copy the KES Server policy before you delete it, as it contains the identities of the Application client certificates.
* When the KES Server is redeployed, a new certificate is generated. You need to fill it in in the MinIO deployments.

## When a MinIO client certificate expires
The MinIO deployments are not stateless. It is probably easiest to generate a new certificate by hand and fill it in in the config map. Restart the MinIO pods. Make sure to update the identity in the KES Server policy.