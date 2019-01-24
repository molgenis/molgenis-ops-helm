# Graphana graphing
Graphana instance graphically displays metrics from one or more
data sources.

## Chart Details
This chart will deploy a grafana instance.

## Authentication
We [delegate grafana authentication to GitHub](http://docs.grafana.org/auth/github/).
Check the credentials on [GitHub](https://github.com/organizations/molgenis/settings/applications/955390)

```
grafana.grafana\.ini.auth\.github.client_id=app id
grafana.grafana\.ini.auth\.github.client_secret=secret
```

To figure out a specific team's id:
* generate a personal github token with `read:org` scope
* use it to fetch the org details:
```
curl -H "Authorization: token <the token>" https://api.github.com/orgs/molgenis/teams
```


