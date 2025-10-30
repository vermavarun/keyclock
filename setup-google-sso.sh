#!/bin/bash

# Keycloak Google SSO Setup Script
# This script configures Google as an identity provider in Keycloak

echo "🚀 Setting up Google SSO for Keycloak..."

# Configuration
KEYCLOAK_URL="http://localhost:8081"
REALM="master"
ADMIN_USER="admin"
ADMIN_PASS="admin123"
PROVIDER_ALIAS="google"

# Function to check if Keycloak is accessible
check_keycloak() {
    echo "📡 Checking Keycloak accessibility..."
    if curl -s -f "${KEYCLOAK_URL}/realms/${REALM}" > /dev/null; then
        echo "✅ Keycloak is accessible"
        return 0
    else
        echo "❌ Keycloak is not accessible at ${KEYCLOAK_URL}"
        echo "Please make sure port-forwarding is active:"
        echo "kubectl port-forward -n keycloak svc/keycloak-service 8081:8080"
        return 1
    fi
}

# Function to get admin access token
get_admin_token() {
    echo "🔑 Getting admin access token..."

    RESPONSE=$(curl -s -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=${ADMIN_USER}" \
        -d "password=${ADMIN_PASS}" \
        -d "grant_type=password" \
        -d "client_id=admin-cli")

    if [ $? -eq 0 ]; then
        ACCESS_TOKEN=$(echo $RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
        if [ -n "$ACCESS_TOKEN" ]; then
            echo "✅ Admin token obtained"
            return 0
        else
            echo "❌ Failed to extract access token from response: $RESPONSE"
            return 1
        fi
    else
        echo "❌ Failed to get admin token"
        return 1
    fi
}

# Function to prompt for Google OAuth credentials
get_google_credentials() {
    echo ""
    echo "📝 Google OAuth Configuration Required"
    echo "======================================"
    echo ""
    echo "Before proceeding, you need to:"
    echo "1. Create a Google Cloud project (if you haven't already)"
    echo "2. Enable Google+ API"
    echo "3. Configure OAuth consent screen"
    echo "4. Create OAuth 2.0 Client credentials"
    echo ""
    echo "Redirect URI to use in Google Console:"
    echo "  ${KEYCLOAK_URL}/realms/${REALM}/broker/google/endpoint"
    echo ""

    read -p "Enter your Google Client ID: " GOOGLE_CLIENT_ID
    read -p "Enter your Google Client Secret: " GOOGLE_CLIENT_SECRET

    if [ -z "$GOOGLE_CLIENT_ID" ] || [ -z "$GOOGLE_CLIENT_SECRET" ]; then
        echo "❌ Both Client ID and Client Secret are required"
        return 1
    fi

    echo "✅ Google credentials provided"
    return 0
}

# Function to check if Google IdP already exists
check_google_idp() {
    echo "🔍 Checking if Google IdP exists..."

    RESPONSE=$(curl -s -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        "${KEYCLOAK_URL}/admin/realms/${REALM}/identity-provider/instances/${PROVIDER_ALIAS}")

    if echo "$RESPONSE" | grep -q "\"alias\":\"${PROVIDER_ALIAS}\""; then
        echo "✅ Google IdP already exists"
        return 0
    else
        echo "ℹ️  Google IdP does not exist"
        return 1
    fi
}

# Function to create Google identity provider
create_google_idp() {
    echo "🏗️  Creating Google identity provider..."

    IDP_DATA='{
        "alias": "'${PROVIDER_ALIAS}'",
        "displayName": "Sign in with Google",
        "providerId": "google",
        "enabled": true,
        "updateProfileFirstLoginMode": "on",
        "trustEmail": true,
        "storeToken": true,
        "addReadTokenRoleOnCreate": false,
        "authenticateByDefault": false,
        "linkOnly": false,
        "firstBrokerLoginFlowAlias": "first broker login",
        "config": {
            "clientId": "'${GOOGLE_CLIENT_ID}'",
            "clientSecret": "'${GOOGLE_CLIENT_SECRET}'",
            "defaultScope": "openid profile email",
            "useJwksUrl": "true",
            "syncMode": "IMPORT"
        }
    }'

    RESPONSE=$(curl -s -w "%{http_code}" -X POST \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$IDP_DATA" \
        "${KEYCLOAK_URL}/admin/realms/${REALM}/identity-provider/instances")

    HTTP_CODE="${RESPONSE: -3}"

    if [ "$HTTP_CODE" = "201" ]; then
        echo "✅ Google IdP created successfully"
        return 0
    else
        echo "❌ Failed to create Google IdP. HTTP Code: $HTTP_CODE"
        echo "Response: ${RESPONSE%???}"
        return 1
    fi
}

# Function to update existing Google identity provider
update_google_idp() {
    echo "🔧 Updating Google identity provider..."

    IDP_DATA='{
        "alias": "'${PROVIDER_ALIAS}'",
        "displayName": "Sign in with Google",
        "providerId": "google",
        "enabled": true,
        "updateProfileFirstLoginMode": "on",
        "trustEmail": true,
        "storeToken": true,
        "addReadTokenRoleOnCreate": false,
        "authenticateByDefault": false,
        "linkOnly": false,
        "firstBrokerLoginFlowAlias": "first broker login",
        "config": {
            "clientId": "'${GOOGLE_CLIENT_ID}'",
            "clientSecret": "'${GOOGLE_CLIENT_SECRET}'",
            "defaultScope": "openid profile email",
            "useJwksUrl": "true",
            "syncMode": "IMPORT"
        }
    }'

    RESPONSE=$(curl -s -w "%{http_code}" -X PUT \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$IDP_DATA" \
        "${KEYCLOAK_URL}/admin/realms/${REALM}/identity-provider/instances/${PROVIDER_ALIAS}")

    HTTP_CODE="${RESPONSE: -3}"

    if [ "$HTTP_CODE" = "204" ]; then
        echo "✅ Google IdP updated successfully"
        return 0
    else
        echo "❌ Failed to update Google IdP. HTTP Code: $HTTP_CODE"
        echo "Response: ${RESPONSE%???}"
        return 1
    fi
}

# Main execution
main() {
    echo "========================================="
    echo "🔧 Keycloak Google SSO Setup"
    echo "========================================="

    # Check Keycloak accessibility
    if ! check_keycloak; then
        exit 1
    fi

    # Get admin token
    if ! get_admin_token; then
        exit 1
    fi

    # Get Google credentials
    if ! get_google_credentials; then
        exit 1
    fi

    # Check if Google IdP exists and create/update accordingly
    if check_google_idp; then
        if ! update_google_idp; then
            exit 1
        fi
    else
        if ! create_google_idp; then
            exit 1
        fi
    fi

    echo ""
    echo "🎉 Google SSO Setup Completed Successfully!"
    echo ""
    echo "📋 Configuration Summary:"
    echo "   - Provider Alias: ${PROVIDER_ALIAS}"
    echo "   - Display Name: Sign in with Google"
    echo "   - Client ID: ${GOOGLE_CLIENT_ID}"
    echo "   - Trust Email: Enabled"
    echo "   - Store Tokens: Enabled"
    echo ""
    echo "🔗 Google OAuth Redirect URI:"
    echo "   ${KEYCLOAK_URL}/realms/${REALM}/broker/google/endpoint"
    echo ""
    echo "🚀 Next Steps:"
    echo "1. Verify Google OAuth client redirect URI matches above"
    echo "2. Test authentication by going to: http://localhost:3000"
    echo "3. You should see 'Sign in with Google' option on login page"
    echo ""
    echo "📖 For detailed setup instructions, see: ./GOOGLE_SSO_SETUP.md"
}

# Run main function
main