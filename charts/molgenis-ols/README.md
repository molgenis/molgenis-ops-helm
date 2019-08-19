# Molgenis OLS Helm chart

This helm chart is used for a test environment for a possible new OLS program.

* Note: This is not a finalized helm chart because we are not certain that we going to use it.
* Note 2: 
Enhancements need to be made if we going to use OLS in production( need to load owl in runtime instead of build time with docker, otherwise it does not scale and take a lot of space on the storage cluster ):
1. Use configMaps to store the addresses where the owl files and config yaml file are stored(website or local)
2. Use init containers to load and index the owl files into the mongodb(docker container)
3. Remove the load and index steps from the docker container and use the steps described above

* Note 3: for this helm chart is htpasswd necessary to be used!

## To start molgenis-ols
### Install htpasswd
If not installed already, use:
```yum install httpd-tools```

### To start it with rancher
If the molgenis-ols chart is loaded, there are a couple of questions to be awnsered.

Website address( default: ols.molgenis.org )
htpassword string(<username>:<password hash>
The htpasswd need to be generated locally on your machine for now. To use it, open command line and type:
```htpasswd -nb <username> <password>```
Copy the appearing string and paste it to the htpassword string awnser.

Let rancher launch the molgenis-logging. After a while you can login with the username and unencrypted password.