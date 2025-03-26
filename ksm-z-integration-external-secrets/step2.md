# Step 2: Deploy and Test the Integration

In this step, we'll deploy a sample application that uses the secrets from KSM and set up automatic reloading when secrets change.

## 1. Install Reloader

First, let's install Stakater Reloader, which will automatically reload our application when secrets change:

```bash
helm repo add stakater https://stakater.github.io/stakater-charts
```{{execute}}

```bash
helm repo update
```{{execute}}

```bash
helm install stakater/reloader --generate-name
```{{execute}}

## 2. Deploy Sample Application

We'll deploy a simple web application that displays environment variables, including our KSM secrets:

```bash
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

## 3. Create Service

Let's create a service to expose our application:

```bash
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

## 4. Test the Integration

You can now access the application at:
[View Running Service]({{TRAFFIC_HOST1_30000}})

The web page will display all environment variables, including:
- `USERNAME_FROM_KEEPER`: The username from your KSM record
- `PASSWORD_FROM_KEEPER`: The password from your KSM record

## How it Works

1. External Secrets Operator syncs secrets from KSM to Kubernetes
2. Our application reads these secrets as environment variables
3. When secrets change in KSM:
   - External Secrets Operator updates the Kubernetes secret
   - Reloader detects the change and restarts the application
   - The application picks up the new secret values

## Next Steps

You've successfully completed the integration! The application will automatically update whenever secrets change in KSM.
