#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a namespace exists
namespace_exists() {
    kubectl get namespace "$1" >/dev/null 2>&1
}

# Function to check if a deployment exists
deployment_exists() {
    kubectl get deployment "$1" -n "$2" >/dev/null 2>&1
}

# Function to check if a service exists
service_exists() {
    kubectl get service "$1" >/dev/null 2>&1
}

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

# Check External Secrets deployment
echo "Checking External Secrets deployment..."
if ! deployment_exists external-secrets external-secrets; then
    echo "❌ External Secrets deployment does not exist"
    exit 1
fi
echo "✅ External Secrets deployment exists"

# Check sample deployment
echo "Checking sample deployment..."
if ! deployment_exists my-deployment default; then
    echo "❌ Sample deployment does not exist"
    exit 1
fi
echo "✅ Sample deployment exists"

# Check service
echo "Checking service..."
if ! service_exists my-service; then
    echo "❌ Service does not exist"
    exit 1
fi
echo "✅ Service exists"

echo "✅ All checks passed!" 