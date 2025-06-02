#!/bin/bash

echo "🚀 Setting up .NET environment and KSM SDK dependencies..."

# Update package lists and install .NET SDK and curl
echo "🔧 Installing .NET SDK (latest) and curl..."
apt update -qq && apt install -y dotnet-sdk-8.0 curl

# Verify .NET installation
dotnet --version

echo "✅ .NET SDK environment setup complete!"
echo "💡 You can now proceed with the KSM .NET SDK tutorial steps." 