#!/bin/bash

# Google OAuth Configuration Checker
# This script helps verify your Google OAuth setup

echo "🔍 Google OAuth Configuration Checker"
echo "====================================="
echo ""

# Configuration
KEYCLOAK_URL="http://localhost:8081"
REALM="master"
EXPECTED_REDIRECT_URI="${KEYCLOAK_URL}/realms/${REALM}/broker/google/endpoint"

echo "📋 Expected Configuration:"
echo "   Keycloak URL: ${KEYCLOAK_URL}"
echo "   Realm: ${REALM}"
echo "   Google IdP Redirect URI: ${EXPECTED_REDIRECT_URI}"
echo ""

echo "🔧 Google Cloud Console Setup Checklist:"
echo ""
echo "1. Go to: https://console.cloud.google.com/"
echo "2. Navigate to: APIs & Services → Credentials"
echo "3. Select your OAuth 2.0 Client ID"
echo "4. In 'Authorized redirect URIs', ensure you have:"
echo "   ✅ ${EXPECTED_REDIRECT_URI}"
echo ""
echo "5. Common wrong URIs to avoid:"
echo "   ❌ http://localhost:3000/callback (This is for React, not Google)"
echo "   ❌ http://localhost:8080/... (Wrong port)"
echo "   ❌ Missing /broker/google/endpoint"
echo ""

echo "🧪 Test Steps:"
echo "1. Make sure port-forwarding is active:"
echo "   kubectl port-forward -n keycloak svc/keycloak-service 8081:8080"
echo ""
echo "2. Make sure React app is running:"
echo "   cd react-keycloak-pkce && npm start"
echo ""
echo "3. Open browser: http://localhost:3000"
echo "4. Click 'Sign in with Google'"
echo "5. Should redirect to Google login without redirect_uri_mismatch error"
echo ""

# Check if Keycloak is accessible
echo "🔍 Checking Keycloak accessibility..."
if curl -s -f "${KEYCLOAK_URL}/realms/${REALM}" > /dev/null 2>&1; then
    echo "✅ Keycloak is accessible at ${KEYCLOAK_URL}"
else
    echo "❌ Keycloak is NOT accessible at ${KEYCLOAK_URL}"
    echo "   Make sure port-forwarding is active!"
fi
echo ""

# Check if Google IdP endpoint exists
echo "🔍 Checking Google IdP endpoint..."
if curl -s -f "${KEYCLOAK_URL}/realms/${REALM}/broker/google/endpoint" > /dev/null 2>&1; then
    echo "✅ Google IdP endpoint is accessible"
else
    echo "❌ Google IdP endpoint not found"
    echo "   Run ./setup-google-sso.sh to configure Google identity provider"
fi
echo ""

# Check React app
echo "🔍 Checking React app..."
if curl -s -f "http://localhost:3000" > /dev/null 2>&1; then
    echo "✅ React app is running at http://localhost:3000"
else
    echo "❌ React app is NOT running"
    echo "   Start with: cd react-keycloak-pkce && npm start"
fi
echo ""

echo "🎯 Quick Fix Summary:"
echo "If you're getting 'redirect_uri_mismatch' error:"
echo "1. Update Google Console redirect URI to: ${EXPECTED_REDIRECT_URI}"
echo "2. Wait 5-10 minutes for changes to propagate"
echo "3. Test again"
echo ""
echo "📖 For detailed instructions, see: ./GOOGLE_OAUTH_FIX.md"