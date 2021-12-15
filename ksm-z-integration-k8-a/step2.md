

Create echo server

`kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4`{{execute}}

View the Deployment

`kubectl get deployments`{{execute}}

View the Pod:

`kubectl get pods`{{execute}}

View cluster events:

`kubectl get events`{{execute}}

View the kubectl configuration:

`kubectl config view`{{execute}}


## Create Secret

### 1. Generate KSM Configuration of K8s:

Commander:


KSM CLI:


Example of the generated config


<pre class="file" data-filename="secret.yml" data-target="replace">
apiVersion: v1
data:
  config: [BASE 64 STRING]
kind: Secret
metadata:
  name: ksm-config
  namespace: default
type: Opaque
</pre>


`kubectl apply -f secret.yml`{{execute}}





]
### OPTIONAL Install KSM CLI Binary on Linux:

Download

`wget -q https://github.com/Keeper-Security/secrets-manager/releases/download/ksm-cli-1.0.6/keeper-secrets-manager-cli-linux-1.0.6.tar.gz`{{execute}}

Extract

`tar -xf keeper-secrets-manager-cli-linux-1.0.6.tar.gz`{{execute}}

Run

`./ksm init k8s [ONE TIME TOKEN] > secret.yml`{{execute}}