# MOLGENIS - frontend

Deploys a molgenis-frontend container in front of a proxied backend.
The incoming traffic is split by the ingresses as follows:

![proxy diagram](molgenis-frontend-proxy.png)

* `/@molgenis-ui` goes to the frontend container
* `/` goes to the backend proxy