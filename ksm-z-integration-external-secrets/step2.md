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
    secret.reloader.stakater.com/reload: "my-external-secrets-values"

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
            
            - name: DEMO_GREETING  # Sample environment variable
              value: "Hello from the environment"
            
            - name: DEMO_FAREWELL  # Sample environment variable
              value: "Such a sweet sorrow"
            
            - name: USERNAME_FROM_KEEPER    # tells Kubernetes to use the value of the username field in the k8s Secret as the value of the environment variable USERNAME_FROM_KEEPER
              valueFrom:
                secretKeyRef:
                    name: my-external-secrets-values
                    key: username
            - name: PASSWORD_FROM_KEEPER    # tells Kubernetes to use the value of the password field in the k8s Secret as the value of the environment variable PASSWORD_FROM_KEEPER
              valueFrom:
                secretKeyRef:
                    name: my-external-secrets-values
                    key: password
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

Look for the environment variables `USERNAME_FROM_KEEPER` and `PASSWORD_FROM_KEEPER`. They should be populated with the values from the Keeper Security record.
