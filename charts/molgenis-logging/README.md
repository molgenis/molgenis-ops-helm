# Molgenis logging Helm chart

This chart is used for logging of the molgenis instances. In the case of logging where logging the access and the error log of the httpd.

* Note: for this helm chart is htpasswd necessary to be used!

## To start molgenis-logging
### Install htpasswd
If not installed already, use:
```yum install httpd-tools```

### To start it with rancher
If the molgenis-logging chart is loaded, there are a couple of questions to be awnsered.

Username Elastic user(for cluster)
Password Elastic password(for cluster)
htpassword string(<username>:<password hash>
The htpasswd need to be generated locally on your machine for now. To use it, open command line and type:
```htpasswd -nb <username> <password>```
Copy the appearing string and paste it to the htpassword string awnser.

Let rancher launch the molgenis-logging. After a while you can login with the username and unencrypted password.