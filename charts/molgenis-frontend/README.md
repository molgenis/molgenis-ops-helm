# MOLGENIS - frontend

Deploys a molgenis-frontend container in front of a proxied backend.
The incoming traffic is split by the ingresses as follows:

* `/@molgenis-ui` goes to the frontend container
* `/` goes to the backend proxy