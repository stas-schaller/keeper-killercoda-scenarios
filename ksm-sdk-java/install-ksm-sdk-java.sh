#!/bin/bash

echo "🚀 Setting up Java environment and KSM SDK dependencies..."

# Update package lists and install OpenJDK 17, Gradle, and curl in a single line
echo "🔧 Installing Java (OpenJDK 17), Gradle, and curl..."
apt update -qq && apt install -y openjdk-17-jdk gradle curl

# Verify installations (already one-liners)
java -version
gradle --version

# Clean up default Gradle project files if they exist (scenario specific) in a single line
echo "🧹 Cleaning up any existing default Gradle project files..."
rm -f src/main/java/com/keepersecurity/ksmsample/App.java 2>/dev/null && rm -f src/test/java/com/keepersecurity/ksmsample/AppTest.java 2>/dev/null

echo "✅ Java SDK environment setup complete!"
echo "💡 You can now proceed with the KSM Java SDK tutorial steps." 