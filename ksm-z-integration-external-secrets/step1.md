
### Install External Secrets Helm Chart

```
helm repo add external-secrets https://charts.external-secrets.io
```{{execute}}

```
helm install external-secrets \
external-secrets/external-secrets \
-n external-secrets \
--create-namespace
```{{execute}}

### Create Secret to store KSM Config Base64
 
Create regular Kubernetes Secret to store KSM Config Base64 
that will be used by External Secrets to authenticate against Keeper Security.

> Replace [KSM CONFIG] with the Base64 encoded KSM Config

```shell
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ksm-config-secret                 # name of the k8s Secret where KSM config is stored
type: Opaque
data:
  ksm_config: "[KSM CONFIG]"                # Base64 encoded KSM Config
EOF
```{{copy}}


### Create SecretStore and ExternalSecret

> Replace [SHARED FOLDER UID] with the UID of the shared folder in Keeper Security where the records are stored.

```shell
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1   
kind: SecretStore
metadata:
  name: my-external-secrets-secretstore   # name of the SecretStore where retrieved secrets will be stored once fetched from Keeper Secrets Manager (KSM)
spec:
  provider:
    keepersecurity:                       # name of the SecretStore provider, in this case KeeperSecurity
      authRef:
        name: ksm-config-secret           # name of the k8s Secret where KSM config is stored
        key: ksm_config                   # key in the k8s Secret where KSM config is stored
      folderID: "[SHARED FOLDER UID]"     # UID of the shared folder in KeeperSecurity where the records 
                                          #   are stored. Make sure the folder is shared into the KSM Application
EOF
```{{copy}}

> Replace [RECORD UID] with the UID of the record in Keeper Security where the secrets are stored.

```shell
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
 name: ksm-external-secret
spec:
 refreshInterval: 1m                      # rate how often SecretManager pulls KeeperSecurity. In this case every minute
 secretStoreRef:                          # tells External Secrets where to store the secrets once fetched from Keeper Security
   kind: SecretStore                      # tells External Secrets the type of the secret store, should be same as the one defined above
   name: my-external-secrets-secretstore  # name of the SecretStore defined above

 dataFrom:                                # tells External Secrets which record to use to fetch from Keeper Secrets Manager (KSM)
   - extract:
       key: "[RECORD UID]"                # UID of the record in Keeper where the secrets are going to be fetched from
 target:                                  # tells External Secrets the target location where to store the secrets once fetched from Keeper Security
   name: my-external-secrets-secretstore-test1 # name of the k8s Secret to be created
   creationPolicy: Owner                  # tells External Secrets to create the k8s Secret if it doesn't exist
   template:
     engineVersion: v2          
     data:
       username: "{{ .login }}"           # tells External Secrets to store the value of 
                                          #   the login field in Keeper Security into the k8s Secret under the key username
       password: "{{ .password }}"        # tells External Secrets to store the value of 
                                          #   the password field in Keeper Security into the k8s Secret under the key password
EOF
```{{execute}}


### Create Simple Kubernetes Deployment to use the secret and print them out on a web page

Sample Deployment to use the secret and print them out on a web page
Here, we will install reloader to auto reload the container if the password was changed in Keeper Security

Steps to install it:
`helm repo add stakater https://stakater.github.io/stakater-charts`{{execute}}
`helm repo update`{{execute}}
`helm install stakater/reloader --generate-name`{{execute}}

```shell
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment                # name of the deployment
  annotations:
    # This is to add auto reload of the container if new password was generated - https://github.com/stakater/Reloader#secret
    # In this case, we are using the secret name "my-external-secrets-secretstore-test1" as the annotation to trigger the reload
    secret.reloader.stakater.com/reload: "my-external-secrets-secretstore-test1"

spec:
  selector:
    matchLabels:
      app: my-app                     # tells Kubernetes to run this application on a pod with the label app: my-app                
  replicas: 1                         # tells Kubernetes to run 1 instance of this application
  template:
    metadata:
      labels:
        app: my-app                  # tells Kubernetes to name the pod(s) with the label app: my-app
    spec:
      containers:
        - name: samplepythonapp       # name of the container
          image: mendhak/http-https-echo    # image to use for the container, in this case a simple pre-built image that prints out information about the request and environment variables
          ports:
            - containerPort: 3000
          env:
            - name: ECHO_INCLUDE_ENV_VARS
              value: "1"
            - name: HTTP_PORT
              value: "3000"
            - name: DEMO_GREETING
              value: "Hello from the environment"
            - name: DEMO_FAREWELL
              value: "Such a sweet sorrow"
      nodeSelector:
        kubernetes.io/os: linux
EOF
```{{execute}}

### Punch a hole in the Kubernetes cluster to expose the service

Create Service to expose the deployment to the outside of the Kubernetes cluster

```shell
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app                      # Search criteria to find the deployment to expose
  ports:
    - name: http
      port: 3000
      targetPort: 3000
      protocol: TCP
      nodePort: 30000
  type: NodePort
EOF
```{{execute}}

### Access the service

[View Running Service]({{TRAFFIC_HOST1_30000}})

