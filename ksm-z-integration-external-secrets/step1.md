
### Option 1: Install chart from Helm repo

Not released yet.
Once released, you can install the chart from the Helm repo. See details [here](https://external-secrets.io/v0.7.2/provider/aws-secrets-manager/)

### Option 2: Install chart from source


Clone repository
`git clone https://github.com/enreach-labs/external-secrets.git`{{exec}}

Navigate to the cloned repository
`cd external-secrets/`{{exec}}

Build the chart
`make helm.build`

<!-- `helm install external-secrets \
./bin/chart/external-secrets.tgz \
-n external-secrets \
--create-namespace` -->


Install the chart (fixed command)
```
helm install external-secrets \
./bin/chart/external-secrets.tgz \
--repo https://charts.external-secrets.io \
--set image.tag=main \
--set webhook.image.tag=main \
--set certController.image.tag=main
```{{exec}}

### Create Kubernetes Secret to store KSM Config Base64

`echo -n 'config-base64' > ./ksm_config`

`kubectl create secret generic ksm-config-secret --from-file=./ksm_config`


### Create your first SecretStore
 
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: secretstore-neeraj-demo
spec:
  provider:
    keepersecurity:
      authRef:
        name: ksm-config-secret
        key: ksm_config.base64
      folderID: "_6JvsBA4hruiICteQe6TFA"
```


