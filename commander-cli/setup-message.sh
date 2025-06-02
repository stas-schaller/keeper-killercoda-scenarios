#!/bin/bash

echo "🔧 Setting up Keeper Commander CLI..."
echo ""

# Wait for the background installation to complete
while [ ! -f /tmp/keeper-setup-complete ]; do
    sleep 1
done

echo ""
echo "✅ Setup complete! You can now proceed with the tutorial."
echo "" 