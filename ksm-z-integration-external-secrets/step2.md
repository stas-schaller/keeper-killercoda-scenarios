step 2


```yaml

#below yaml to replace following cli:
#  `echo -n 'config-base64' > ./ksm_config`
#  `kubectl create secret generic ksm-config-secret --from-file=./ksm_config`

apiVersion: v1
kind: Secret
metadata:
  name: ksm-config-secret
type: Opaque
data:
  ksm_config: "BASE64_ENCODED_KSM_CONFIG"

---

apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: secretstore-neeraj-demo
spec:
  provider:
    keepersecurity:
      authRef:
        name: ksm-config-secret
        key: ksm_config
      folderID: "_6JvsBA4hruiICteQe6TFA" 

---

apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
 name: ksm-external-secret
spec:
 refreshInterval: 20s               # rate SecretManager pulls KeeperSecurity
 secretStoreRef:
   kind: SecretStore
   name: secretstore-neeraj-demo               # name of the SecretStore (or kind specified)
 target:
   name: a-secret-from-neeraj-demo  # name of the k8s Secret to be created
   creationPolicy: Owner
   template:
     engineVersion: v2
     data:
       username: "{{ .login }}"
       password: "{{ .password }}"

 dataFrom:
   - extract:
       key: ilENQmk2iMqnrMTzpWMeFA  # ID of the Keeper Record


---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  annotations:
    # This is to add auto reload of the container if new password was generated
    # https://github.com/stakater/Reloader#secret

    secret.reloader.stakater.com/reload: "a-secret-from-neeraj-demo"
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80

          env:
            - name: SOME_ENV_VAR_VALUE
              valueFrom:
                secretKeyRef:
                  name: a-secret-from-neeraj-demo
                  key: password
```