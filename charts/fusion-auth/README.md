# Fusion

## Restore
When you remove the application you need to remember three things:

- namespace (eg. fusion-auth)
- name of pvc (eg. data-postgresql-0)
- name of pv (eg. pvc-xxxx-xxxx-xxxx-xxxx)

There are 2 policies you can assign to a volume; retain or delete. This implies two restore flows as well.

## Retain policy
You need to make sure the namespace is deleted. The volumeclaim is then deleted as well and the pv is in the "Released" state.
When you run the command below you make it available again, using the Rancher client:

```bash
\> # to show how the volume is named and if it is in the "Released state"
\> rancher kubectl get pv | grep fusion
\> # output
\> data-postgresql-0  8Gi  RWO  Retain  Released  fusion-auth/data-postgresql-0  nfs-provisioner-retain  20h

\> # make the volume available again for another pvc
\> rancher kubectl patch pv data-postgresql-0 -p '{"spec":{"claimRef": null}}'
```

## Delete policy
The delete policy is a bit trickier. You need to build the volume from scratch. You need to specify 6 properties:
- name
- volume plugin - *NFS Share*
- Capacity - *8GB*
- Path
  > is the directory on the NFS share. When the volume is deleted from cluster it will be archived.
  > the name of the directory is *archived-#namespace#-#pvc-name#-#pv-name#*, this is the mount path (except when you change the directory ;-D)
- Server - *192.168.64.160*
- Access mode - *Single Node Read-Write*

## Create the persistent volume claim
Now you can create a new pvc bind to the volume of the fusion-auth you created or made available again. You need to specify 3 things: 
- namespace
  > needs to be the same as you are going to deploy the application in
- persistent volume
- Access modes 
  > needs to be the same as the access mode specified in the volume

## Deploy app
Specify in the form on the Rancher UI the exisiting claim name. Which has to be the same as you specified in the name of the pvc. 
> make sure you deploy in the same namespace as the pvc is in.