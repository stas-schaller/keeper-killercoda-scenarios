#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a namespace exists
namespace_exists() {
    kubectl get namespace "$1" >/dev/null 2>&1
}

# Function to check if a deployment exists and is available
deployment_available() {
    kubectl get deployment "$1" -n "$2" >/dev/null 2>&1 && \
    kubectl wait --for=condition=available --timeout=10s deployment/"$1" -n "$2" >/dev/null 2>&1
}

# Function to check if a secret exists
secret_exists() {
    kubectl get secret "$1" >/dev/null 2>&1
}

# Function to check if a SecretStore exists
secretstore_exists() {
    kubectl get secretstore "$1" >/dev/null 2>&1
}

# Function to check if an ExternalSecret exists
externalsecret_exists() {
    kubectl get externalsecret "$1" >/dev/null 2>&1
}

# Function to check if a CRD exists
crd_exists() {
    kubectl get crd "$1" >/dev/null 2>&1
}

echo "🔍 Verifying External Secrets Integration Setup..."

# Check for required tools
echo "Checking required tools..."
if ! command_exists helm; then
    echo "❌ Helm is not installed"
    exit 1
fi
if ! command_exists kubectl; then
    echo "❌ kubectl is not installed"
    exit 1
fi
echo "✅ Required tools are installed"

# Check External Secrets namespace
echo "Checking External Secrets namespace..."
if ! namespace_exists external-secrets; then
    echo "❌ external-secrets namespace does not exist"
    exit 1
fi
echo "✅ external-secrets namespace exists"

# Check External Secrets deployments are available
echo "Checking External Secrets operator deployments..."
if ! deployment_available external-secrets external-secrets; then
    echo "❌ External Secrets operator deployment is not available"
    exit 1
fi
if ! deployment_available external-secrets-webhook external-secrets; then
    echo "❌ External Secrets webhook deployment is not available"
    exit 1
fi
if ! deployment_available external-secrets-cert-controller external-secrets; then
    echo "❌ External Secrets cert-controller deployment is not available"
    exit 1
fi
echo "✅ External Secrets operator deployments are available"

# Check required CRDs exist
echo "Checking External Secrets CRDs..."
if ! crd_exists secretstores.external-secrets.io; then
    echo "❌ SecretStore CRD does not exist"
    exit 1
fi
if ! crd_exists externalsecrets.external-secrets.io; then
    echo "❌ ExternalSecret CRD does not exist"
    exit 1
fi
echo "✅ External Secrets CRDs exist"

# Check KSM config secret exists
echo "Checking KSM configuration secret..."
if ! secret_exists ksm-config-secret; then
    echo "❌ KSM config secret does not exist"
    exit 1
fi
echo "✅ KSM config secret exists"

# Check SecretStore exists
echo "Checking SecretStore..."
if ! secretstore_exists my-external-secrets-secretstore; then
    echo "❌ SecretStore does not exist"
    exit 1
fi
echo "✅ SecretStore exists"

# Check ExternalSecret exists
echo "Checking ExternalSecret..."
if ! externalsecret_exists ksm-external-secret; then
    echo "❌ ExternalSecret does not exist"
    exit 1
fi
echo "✅ ExternalSecret exists"

echo "🎉 All Step 1 checks passed! External Secrets integration is properly configured." 