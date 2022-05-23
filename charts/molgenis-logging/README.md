# Molgenis logging Helm chart

## version >= 1.0.0

This chart with this version is used for central storing of logs of the molgenis instances. We are logging:
- tomcat logs
- postgresql logs
- elasticsearch logs
- web server logs
- molgenis logs
- emx2 logs

## version < 1.0.0

This chart with this version is used for central storing of logs of all the rancher pods. We are logging all the different pods on the rancher dev cluster.

* Note: for both this two versions of helm chart is htpasswd necessary to be used!

## To start molgenis-logging
### Install htpasswd
If not installed already, use:
```yum install httpd-tools```

### To start it with rancher
If the molgenis-logging chart is loaded, there are a couple of questions to be awnsered.

Username Elastic user(for cluster)
Password Elastic password(for cluster)

Let rancher launch the molgenis-logging. After a while you can login with the username and unencrypted password.