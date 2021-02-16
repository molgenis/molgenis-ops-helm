# KES server

The KES server is used by MinIO to generate encryption keys on HashiCorp Vault.
The server itself is stateless.

The server runs inside your cluster, using its own TLS.
The MinIO server must trust the CA certificate this server uses to identify itself.