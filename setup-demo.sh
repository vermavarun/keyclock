#!/bin/bash

# Keycloak + React PKCE Demo Setup Script
# This script helps you get the complete demo up and running

echo "🚀 Keycloak + React PKCE Demo Setup"
echo "=================================="
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking Prerequisites..."

if ! command_exists kubectl; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

if ! command_exists node; then
    echo "❌ Node.js is not installed. Please install Node.js (v16+) first."
    exit 1
fi

if ! command_exists npm; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

echo "✅ All prerequisites are available!"
echo

# Check if Keycloak is running
echo "🔍 Checking Keycloak Status..."
if kubectl get pods -n keycloak &>/dev/null; then
    READY_PODS=$(kubectl get pods -n keycloak -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | tr ' ' '\n' | grep -c "True")
    TOTAL_PODS=$(kubectl get pods -n keycloak -o jsonpath='{.items[*].metadata.name}' | wc -w | tr -d ' ')

    if [ "$READY_PODS" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -gt 0 ]; then
        echo "✅ Keycloak is running ($READY_PODS/$TOTAL_PODS pods ready)"
    else
        echo "⚠️  Keycloak pods are not ready ($READY_PODS/$TOTAL_PODS)"
        echo "Deploying Keycloak..."
        kubectl apply -f deploy-keyclock.yaml
        echo "Waiting for Keycloak to be ready..."
        kubectl wait --for=condition=ready pod -l app=keycloak -n keycloak --timeout=300s
        echo "✅ Keycloak is now ready!"
    fi
else
    echo "❌ Keycloak namespace not found. Deploying Keycloak..."
    kubectl apply -f deploy-keyclock.yaml
    echo "Waiting for Keycloak to be ready..."
    kubectl wait --for=condition=ready pod -l app=keycloak -n keycloak --timeout=300s
    echo "✅ Keycloak deployed successfully!"
fi
echo

# Start port-forwarding
echo "🔌 Starting Port-Forward..."
PORT_FORWARD_PID=$(pgrep -f "kubectl port-forward.*keycloak-service.*8081:8080" | head -1)
if [ -n "$PORT_FORWARD_PID" ]; then
    echo "✅ Port-forward already running (PID: $PORT_FORWARD_PID)"
else
    echo "Starting port-forward to Keycloak..."
    kubectl port-forward -n keycloak svc/keycloak-service 8081:8080 >/dev/null 2>&1 &
    PORT_FORWARD_PID=$!
    sleep 3
    echo "✅ Port-forward started (PID: $PORT_FORWARD_PID)"
fi
echo

# Setup React app
echo "⚛️  Setting up React App..."
cd react-keycloak-pkce || exit 1

if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
else
    echo "✅ Dependencies already installed"
fi
echo

# Provide setup instructions
echo "🎉 Setup Complete!"
echo "=================="
echo
echo "Next steps:"
echo "1. 🌐 Access Keycloak Admin Console:"
echo "   URL: http://localhost:8081/admin/"
echo "   Username: admin"
echo "   Password: admin123"
echo
echo "2. 🔧 Configure Keycloak Client (if not done already):"
echo "   - Go to Clients → Create Client"
echo "   - Client ID: react-pkce-client"
echo "   - Client Type: OpenID Connect"
echo "   - Public client (no authentication)"
echo "   - Valid redirect URIs: http://localhost:3000/callback"
echo "   - Web origins: http://localhost:3000"
echo "   - Enable PKCE (S256)"
echo
echo "3. 🚀 Start the React App:"
echo "   cd react-keycloak-pkce"
echo "   npm start"
echo
echo "4. 🌟 Open the Demo:"
echo "   http://localhost:3000"
echo
echo "📖 For detailed setup instructions, see:"
echo "   - Main README: ./readme.md"
echo "   - React README: ./react-keycloak-pkce/README.md"
echo
echo "🎯 Happy coding! The demo showcases secure PKCE authentication flow."