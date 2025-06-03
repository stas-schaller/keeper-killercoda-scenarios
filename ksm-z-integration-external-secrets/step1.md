# Step 1: Configure External Secrets

In this step, we'll set up the External Secrets Operator and configure it to work with Keeper Security Manager (KSM).

## 1. Install External Secrets Operator

First, let's add the External Secrets Helm repository and install the operator:

```bash
helm repo add external-secrets https://charts.external-secrets.io
```{{execute}}

```bash
helm install external-secrets \
external-secrets/external-secrets \
-n external-secrets \
--create-namespace \
--wait
```{{execute}}

## 2. Wait for External Secrets Operator to be Ready

Let's ensure the External Secrets Operator is fully ready before proceeding:

```bash
kubectl wait --for=condition=available --timeout=300s deployment/external-secrets -n external-secrets
```{{execute}}

```bash
kubectl wait --for=condition=available --timeout=300s deployment/external-secrets-webhook -n external-secrets
```{{execute}}

```bash
kubectl wait --for=condition=available --timeout=300s deployment/external-secrets-cert-controller -n external-secrets
```{{execute}}

## 3. Verify CRDs are Available

Let's verify that the Custom Resource Definitions are properly installed:

```bash
kubectl wait --for condition=established --timeout=60s crd/secretstores.external-secrets.io
```{{execute}}

```bash
kubectl wait --for condition=established --timeout=60s crd/externalsecrets.external-secrets.io
```{{execute}}

```bash
kubectl get crd | grep external-secrets
```{{execute}}

## 4. Create KSM Configuration Secret

We need to create a Kubernetes secret to store the KSM configuration. This secret will be used by External Secrets to authenticate with Keeper Security.

> **Important**: Replace `[KSM CONFIG]` with your Base64 encoded KSM configuration.

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ksm-config-secret                 # name of the k8s Secret where KSM config is stored
type: Opaque
data:
  ksm_config: "[KSM CONFIG]"             # Base64 encoded KSM Config
EOF
```{{copy}}

## 5. Create SecretStore

The SecretStore defines how External Secrets should connect to KSM. We'll create one that uses our KSM configuration secret.

> **Important**: Replace `[SHARED FOLDER UID]` with the UID of your Keeper Security shared folder.

```bash
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1   
kind: SecretStore
metadata:
  name: my-external-secrets-secretstore   # name of the SecretStore where retrieved secrets will be stored
spec:
  provider:
    keepersecurity:                       # name of the SecretStore provider
      authRef:
        name: ksm-config-secret           # name of the k8s Secret where KSM config is stored
        key: ksm_config                   # key in the k8s Secret where KSM config is stored
      folderID: "[SHARED FOLDER UID]"     # UID of the shared folder in KeeperSecurity
                                          # Make sure the folder is shared with the KSM Application
EOF
```{{copy}}

## 6. Create ExternalSecret

Finally, we'll create an ExternalSecret that defines which secrets to fetch from KSM and how to store them in Kubernetes.

> **Important**: Replace `[RECORD UID]` with the UID of your Keeper Security record.

```bash
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ksm-external-secret
spec:
  refreshInterval: 30s                    # How often to sync secrets from KSM
                                          # Recommended: 30 minutes or more for production
  secretStoreRef:                         # Reference to the SecretStore
    kind: SecretStore
    name: my-external-secrets-secretstore  

  dataFrom:                               # Which record to fetch from KSM
    - extract:
        key: "[RECORD UID]"               # UID of the Keeper record
  target:                                 # Where to store the secrets
    name: my-external-secrets-values      # Name of the k8s Secret to create
    creationPolicy: Owner                 # Create the k8s Secret if it doesn't exist
    template:
      engineVersion: v2          
      data:
        username: "{{ .login }}"          # Map Keeper login field to username
        password: "{{ .password }}"       # Map Keeper password field to password
EOF
```{{copy}}

## Next Steps

In the next step, we'll deploy a sample application that uses these secrets to demonstrate the integration in action.
