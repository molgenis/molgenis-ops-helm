# variant-formatter
This chart deploys a docker container that uses biocommons hgvs tooling to format variants.

The biocommons tooling requires relatively large bodies of reference information, in particularly

* UTA -> a postgres database with transcript locations
* seqrepo -> a directory with files containing the reference genome

## UTA
Uses the postgres subchart with an init script adapted from
https://github.com/biocommons/uta/blob/master/misc/docker/load-uta.sh

It downloads a database export from http://dl.biocommons.org/uta/ and imports it
into the uta database.
The `uta.version` value allows you to specify which version is downloaded.
N.B. There also is a UTA REST service that we should consider upgrading to.

### latest versions are really slow
See https://github.com/biocommons/uta/issues/228
The uta repo still does get updated but the postgres script distributed in that repo has a couple
of really expensive `REFRESH MATERIALIZED VIEW` statements that take hours to complete.

They say they will fix it eventually but haven't yet.
A workaround would be to remove the statements from the import script,
as described in https://github.com/biocommons/uta/issues/228#issuecomment-734134693

```
gzip -cdq uta_${UTA_VERSION}.pgd.gz | grep -v "^REFRESH MATERIALIZED VIEW" | psql -h localhost -U uta_admin --echo-errors --single-transaction -v ON_ERROR_STOP=1 -d uta
```


## seqrepo
The pod contains an init container that runs the biocommons/seqrepo container.
See https://github.com/biocommons/biocommons.seqrepo
It downloads the ref seq data from http://dl.biocommons.org/seqrepo/
to a mounted volume that it shares with the variant formatter container.

The `seqrepo.image.tag` value allows you to specify which tag of the container is run.

## variant formatter
Runs a container built in https://github.com/molgenis/molgenis-ops-docker/tree/master/prod/variant-formatter

The `image.tag` value allows you to specify which tag of the container is run.

## other hgvs-based containers
The chart can also be used as a basis to run other hgvs-based containers, that
require the uta and refseq to be present.
We may want to share a single deployment of UTA and refseq between such services,
or to replace the current crude formatter with something more sophisticated.
