# Lifelines edge server

Deploys a node server that allows integration between the lifelines webshop and
the crm and lifelines.

The server runs a [molgenis/molgenis-node-lifelines-edge](https://hub.docker.com/repository/docker/molgenis/molgenis-node-lifelines-edge) container.
It gets proxied in front of the lifelines web shop MOLGENIS backend and acts on
specific requests.