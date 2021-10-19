

### Generate one time token using Web Vault or Commander

More info can be found [HERE](????)


### Generate secret file.

Replace `XX:XXXXXXXXXXX` with one time token

`ksm init k8s XX:XXXXXXXXXXX > ksm-config-secret.yaml`{{copy}}

### Apply generated yaml file to k8s cluster

`kubectl apply -f ksm-config-secret.yaml`{{execute}}

### Delete file

`rm -f ksm-config-secret.yaml`{{execute}}


### Check if secret was deployed to K8s cluster

`kubectl get secret`{{execute}}