# MOLGENIS Armadillo

This chart deploys a MOLGENIS Armadillo server with an RServe backend and a minio file store.

Data managers can upload data sets into the file store. Researchers can analyze these data sets across multiple instances using DataSHIELD.

## MinIO file encryption
By default the chart encrypts the files in MinIO using a KES server.
The MinIO server communicates with the KES server using mutual TLS.

The KES server's public certificate needs to be trusted by MinIO.
There's a rancher question where you must fill it in.
You can find it in the kes server's secret.

When deployed, this chart generates a key pair client.key and client.cert to use in communication with the server.
It also creates two jobs.
The first job logs the identity of the client certificate.
Upgrade the KES server, adding a policy that allows the MinIO client key to use a 
specific KES key. So for example if your deployment is going to use a key named gecko, add this to the KES server's policy:
```
gecko:
  paths:
    - /v1/key/create/gecko*
    - /v1/key/generate/gecko*
    - /v1/key/decrypt/gecko*
  identities:
    - <here you fill in the client key identity logged by the job>
```
Then restart the kes pods so that they pick up the policy.

The second job tries to create the key on the kes server (MinIO won't do that for you).
Initially it will fail because the policy forbids key creation.
It should succeed once the policy is configured and the kes pods have restarted.

After six tries the job gives up. But if you delete the failed job pods it will start trying again.
If the key has already been created, it will fail but with a message that says so.
The jobs are only there for your convenience, feel free to delete them once everything is set up correctly.

> We use the Armadillo icon from: [Armadillo vectors by vecteezy](https://www.vecteezy.com/free-vector/armadillo)