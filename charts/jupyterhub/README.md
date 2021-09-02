# Jupyter
Jupyter Helm.

## Setup a jupyter environment
To spin up a Jupyter cluster: https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/installation.html.

### Resources assignment MiniKube
`minikube delete && minikube start --cpus 4 --memory 8192`

### To initialise loadbalancer within MiniKube
`minikube tunnel`

### Local settings
Enable `ingress`. Make sure you have the `minikube tunnel` open.

### Install a new release of jupiter
```bash
helm upgrade --cleanup-on-fail \
  --install jupyter . \
  --namespace jupyter \
  --version=1.0.0 \
  --create-namespace \
  --timeout 10m0s 
```

The instance will exposed on http://127.0.0.1.
### OIDC roles in JupyterHub
In the ID-provider you can supply a set of roles. At this moment in JupyterHub we support 2 roles:

- **USER**: can see all profiles and use them
- **ADMIN**: can administrate JupyterHub

With the `ADMIN` role you can appoint administrators on the cluster. The `USER` role people can access the profiles defined in the cluster.

> IMPORTANT: once you gave someone the `ADMIN` role you need to remove it in JupyterHub as well.
## Troubleshooting
### Generating the proxy token
You can generate proxy token: `openssl rand -hex 32`

### Timeout when starting a notebook (500 error)
Get container logging from the notebook: `kubectl logs #pod# -c notebook -n jupyter`. 
If the container logging does not work can run it locally by executing:
`docker run -ti molgenis/rstudio-jupyter:x.x.x /usr/lib/rstudio-server/bin/rserver`
You check the output for errors.

### Timeout during image pulls
Sometimes a cluster takes too long to pull the image of RStudio. The images of RStudio are rather large. Most of them are between 1G and 1.5G. This takes approximatly 7 minutes. This is often too long ofor Rancher.

You deploy the image first in a simple deployment and then deploy the JupyterHub (or extra profiles). This way the deployment of JupyterHub does not crash.
