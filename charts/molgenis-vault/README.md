# MOLGENIS Vault helm chart

This chart creates a vault operator, but NO vault.

## Deploy
The deployment of the Vault consists of 7 steps.

**In Rancher**
2. Deploy hashicorp vault in prod to the vault namespace

*Context == prod-molgenis*

3. *Add NodePort service to expose to other clusters*

   Create a NodePort service on top of the Vault service
   ```rancher kubectl create -f resources/vault-nodeport.yaml --namespace vault-operator```

4. *Restore backup*

   Copy the persistent volume tied to the current deployment
   Create a new persistent volume based upon the new directory


6. *Unlock the Vault*

   There are 2 Vault services which need to be unlocked.
   ```rancher kubectl describe vault --namespace vault-operator```
   You need to look here:
   ```
   Vault Status:
     Active:
     Sealed:
       **vault-79f8d698fb-5thm2**
       **vault-79f8d698fb-wh8js**
     Standby:  <nil>
   ```
   Proxy-forward the Vault service to be able to make use of the client.
   ```
   rancher kubectl port-forward #vault-pod# 8200 --namespace vault-operator
   ```
   Install Vault client: https://www.vaultproject.io/docs/install/
   You need to add this line to your `.profile`:
   ```
   export VAULT_SKIP_VERIFY=1
   ```
   Then execute the following commands:
   ```
   vault status
   ```
   Execute this three times (because of the three key encryption method)
   ```
   vault operator unseal
   ```
   Run `vault status` again to check if the Vault is unsealed.

   > IMPORTANT: You can unseal in the UI as well

**In Jenkins**

7. The NodePort is random so you need to configure it in the Kubernetes secret 

   (Rancher --> dev-molgenis project): `molgenis-pipeline-vault-secret` with key `addr`. E.g. 'https://192.168.64.161:30221'.
   (Go to the `prod-molgenis` project and select **Resources** --> **Secrets**).

## Configure OpenID connect server
Check: [OIDC in Hashicorp Vault](https://learn.hashicorp.com/vault/operations/oidc-auth)

### Add application in Fusion (OpenID connect server)
First you need to logon to the Fusion server ([https://auth.molgenis.org](https://auth.molgenis.org))

#### Then create an application
Navigate to "Applications" and click on the plus-sign

![Create Fusion App](https://raw.githubusercontent.com/molgenis/molgenis-ops-helm/master/charts/molgenis-vault/docs/imgs/fusion-app-create.png)

#### Configure the application
Please note you need to fill the authorized redirect urls of the vault ([https://vault.molgenis.org](https://vault.molgenis.org)). 
- UI: https://vault.molgenis.org/ui/vault/auth/oidc/oidc/callback
- CLI: https://vault.molgenis.org/oidc/callback

![Configure application](https://raw.githubusercontent.com/molgenis/molgenis-ops-helm/master/charts/molgenis-vault/docs/imgs/fusion-app-configure.png)



### Configure OID in the Vault
Obtain the root token from the designated location. Logon to the [https://vault.molgenis.org](https://vault.molgenis.org).

Navigate to *Access* and click on *Enable new method*

![New vault auth](https://raw.githubusercontent.com/molgenis/molgenis-ops-helm/master/charts/molgenis-vault/docs/imgs/vault-auth-enable.png)

Select *OIDC*

![Select OIDC](https://raw.githubusercontent.com/molgenis/molgenis-ops-helm/master/charts/molgenis-vault/docs/imgs/vault-auth-select-oicd.png)

Configure the OIDC method by:
1. Fill in the discovery url obtained from the authentication server (https://auth.molgenis.org)
2. Add a *Default role*
> you need to add the role via CLI as well.
3. Add the ClientID and ClientSecret

![OIDC Configuration](https://raw.githubusercontent.com/molgenis/molgenis-ops-helm/master/charts/molgenis-vault/docs/imgs/vault-auth-configuration.png)

#### Add roles to OIDC in the vault
You can define roles in the vault, that get assigned based on the claims in the ID token:
```
{
  "allowed_redirect_uris": [
    "https://vault.molgenis.org/ui/vault/auth/oidc/oidc/callback",
    "https://vault.molgenis.org/oidc/callback"
  ],
  "bound_audiences": [
    // The ID Provider sets the 'aud' claim in the ID token
    // to the clientID of the vault application.
    // The vault must check that it is the intended audience.
    "7a92e810-fd6b-44ad-b2c9-8461abf5de78"
  ],
  "bound_claims": {
    // This role can only be assumed if the 'roles' claim in the ID token
    // contains 'dev'
    "roles": "dev"
  },
  "policies": [
    // these policies are applied
    "default",
    "secret-reader",
    "dev-secret-manager"
  ],
  // this claim is mapped to the username
  "user_claim": "email"
}
```

```bash
vault write auth/oidc/role/dev @role-dev.json
vault write auth/oidc/role/ops @role-ops.json
```



### Mapping roles from Fusion to the Vault
You can manage roles and groups in Fusion and use them in the Vault. The following configuration shows you how to do that.

#### Add role to application in Fusion
Navigate to "Applications" and select "Manage roles"

![Add application role](https://raw.githubusercontent.com/molgenis/molgenis-ops-helm/master/charts/molgenis-vault/docs/imgs/fusion-app-add-role.png)

Create a role.

![Application role details](https://raw.githubusercontent.com/molgenis/molgenis-ops-helm/master/charts/molgenis-vault/docs/imgs/fusion-app-role-details.png)

#### Add registration to user
First navigate to "Users" --> "Select a user" --> "Manage user"

![Manage user](https://raw.githubusercontent.com/molgenis/molgenis-ops-helm/master/charts/molgenis-vault/docs/imgs/fusion-user-manage.png)

Click on "Add registration"

![Add user registration](https://raw.githubusercontent.com/molgenis/molgenis-ops-helm/master/charts/molgenis-vault/docs/imgs/fusion-user-add-registration.png)

Select "Vault" and select the applicable role "dev".

![User registration details](https://raw.githubusercontent.com/molgenis/molgenis-ops-helm/master/charts/molgenis-vault/docs/imgs/fusion-user-registration-details.png)


You're set to login with OIDC.