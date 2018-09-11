# MOLGENIS
This chart is used for acceptance and production use cases.

## Containers
This chart spins up a MOLGENIS instance with HTTPD. The created containers are:

- MOLGENIS

## Provisioning
You can choose from which registry you want to pull. There are 2 registries:
- https://registry.molgenis.org
- https://hub.docker.com

The registry.molgenis.org contains the bleeding edge versions (PR's and master merges). The hub.docker.com contains the released artifacts (MOLGENIS releases and release candidates).

The three properties you need to specify are:
- ```molgenis.image.repository```
- ```molgenis.image.name```
- ```molgenis.image.tag```

Besides determining which image you want to pull, you also have to set an administrator password. You can do this by specifying the following property. 
- ```molgenis.adminPassword```

If you do not specify a password. You can find a one time password in the MOLGENIS container logging.

## Services
When you start MOLGENIS you need:
- an elasticsearch instance (5.5.6) 
- an postgres instance (9.6)

You can attach additional services like:
- an opencpu instance

### Elasticsearch
You can configure elasticsearch by giving in the cluster location.

To configure the transport address you can address the node communication channel but also the native JAVA API. Which MOLGENIS uses to communicate with Elasticsearch.
From Elasticsearch version 6 and further the JAVA API is not supported anymore. At this moment you can only use Elastic instance till major version 5.
- ```molgenis.services.elasticsearch.transportAddresses: localhost:9300```

To configure the index on a Elasticsearch cluster you can specify the clusterName property.
- ```molgenis.services.elasticsearch.clusterName: molgenis```

### Postgres
You can specify the location of the postgres instance by specify the following property:
- ```molgenis.services.postgres.host: localhost```

You can specify the schema by filling out this property:
- ```molgenis.services.postgres.scheme: molgenis```

You can specify credentials for the database scheme by specifying the following properties:
- ```molgenis.services.postgres.user: molgenis```
- ```molgenis.services.postgres.password: molgenis```

To test you can use the **PostgreSQL**-helm chart of Kubernetes and specify these answers:

```bash
# answers for postgresql chart
postgresUser=molgenis
postgresPassword=molgenis
postgresDatabase=molgenis
persistence.enabled=false
```

### OpenCPU
You can specify the location of the OpenCPU cluster by specifying this property:
- ```molgenis.services.opencpu.host: localhost```

You can test OpenCPU settings using the **OpenCPU**-helm chart of MOLGENIS.

## Resources
You can specify resources by resource type. There are 2 resource types.
- memory of container
- maximum heap space JVM

Specify memory usage of container:
- ```molgenis.resources.limits.memory```

Specify memory usage for Java JVM:
- ```molgenis.javaOpts.maxHeapSpace```

Select the resources you need dependant on the customer you need to serve.

## Firewall
Is defined at cluster level. This chart does not facilitate firewall configuration.
