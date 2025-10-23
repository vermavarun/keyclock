#!/bin/bash

# Keycloak Client Setup Script
# This script will create the required client in Keycloak for PKCE authentication

echo "🚀 Setting up Keycloak client for React PKCE authentication..."

# Keycloak configuration
KEYCLOAK_URL="http://localhost:8081"
REALM="master"
ADMIN_USER="admin"
ADMIN_PASS="admin123"
CLIENT_ID="react-pkce-client"

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

# Function to check if client exists
client_exists() {
    echo "🔍 Checking if client '${CLIENT_ID}' exists..."

    RESPONSE=$(curl -s -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        "${KEYCLOAK_URL}/admin/realms/${REALM}/clients?clientId=${CLIENT_ID}")

    if echo "$RESPONSE" | grep -q "\"clientId\":\"${CLIENT_ID}\""; then
        echo "✅ Client '${CLIENT_ID}' already exists"
        return 0
    else
        echo "ℹ️  Client '${CLIENT_ID}' does not exist"
        return 1
    fi
}

# Function to create the client
create_client() {
    echo "🏗️  Creating client '${CLIENT_ID}'..."

    CLIENT_DATA='{
        "clientId": "'${CLIENT_ID}'",
        "name": "React PKCE Client",
        "description": "React app using PKCE authentication flow",
        "protocol": "openid-connect",
        "publicClient": true,
        "standardFlowEnabled": true,
        "directAccessGrantsEnabled": true,
        "implicitFlowEnabled": false,
        "serviceAccountsEnabled": false,
        "authorizationServicesEnabled": false,
        "fullScopeAllowed": true,
        "nodeReRegistrationTimeout": 0,
        "defaultClientScopes": ["web-origins", "acr", "profile", "roles", "email", "offline_access"],
        "optionalClientScopes": ["address", "phone", "microprofile-jwt"],
        "attributes": {
            "pkce.code.challenge.method": "S256",
            "post.logout.redirect.uris": "http://localhost:3000/",
            "oauth2.device.authorization.grant.enabled": false,
            "oidc.ciba.grant.enabled": false,
            "backchannel.logout.session.required": true,
            "backchannel.logout.revoke.offline.tokens": false
        },
        "redirectUris": ["http://localhost:3000/callback"],
        "webOrigins": ["http://localhost:3000"],
        "rootUrl": "http://localhost:3000",
        "baseUrl": "http://localhost:3000",
        "adminUrl": ""
    }'

    RESPONSE=$(curl -s -w "%{http_code}" -X POST \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$CLIENT_DATA" \
        "${KEYCLOAK_URL}/admin/realms/${REALM}/clients")

    HTTP_CODE="${RESPONSE: -3}"

    if [ "$HTTP_CODE" = "201" ]; then
        echo "✅ Client '${CLIENT_ID}' created successfully"
        return 0
    else
        echo "❌ Failed to create client. HTTP Code: $HTTP_CODE"
        echo "Response: ${RESPONSE%???}"
        return 1
    fi
}

# Function to update existing client
update_client() {
    echo "🔧 Updating client configuration..."

    # Get client UUID first
    CLIENT_UUID=$(curl -s -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        "${KEYCLOAK_URL}/admin/realms/${REALM}/clients?clientId=${CLIENT_ID}" | \
        grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

    if [ -z "$CLIENT_UUID" ]; then
        echo "❌ Could not get client UUID"
        return 1
    fi

    CLIENT_DATA='{
        "clientId": "'${CLIENT_ID}'",
        "name": "React PKCE Client",
        "description": "React app using PKCE authentication flow",
        "protocol": "openid-connect",
        "publicClient": true,
        "standardFlowEnabled": true,
        "directAccessGrantsEnabled": true,
        "implicitFlowEnabled": false,
        "serviceAccountsEnabled": false,
        "authorizationServicesEnabled": false,
        "fullScopeAllowed": true,
        "defaultClientScopes": ["web-origins", "acr", "profile", "roles", "email", "offline_access"],
        "optionalClientScopes": ["address", "phone", "microprofile-jwt"],
        "attributes": {
            "pkce.code.challenge.method": "S256",
            "post.logout.redirect.uris": "http://localhost:3000/",
            "oauth2.device.authorization.grant.enabled": false,
            "oidc.ciba.grant.enabled": false,
            "backchannel.logout.session.required": true,
            "backchannel.logout.revoke.offline.tokens": false
        },
        "redirectUris": ["http://localhost:3000/callback"],
        "webOrigins": ["http://localhost:3000"],
        "rootUrl": "http://localhost:3000",
        "baseUrl": "http://localhost:3000"
    }'

    RESPONSE=$(curl -s -w "%{http_code}" -X PUT \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$CLIENT_DATA" \
        "${KEYCLOAK_URL}/admin/realms/${REALM}/clients/${CLIENT_UUID}")

    HTTP_CODE="${RESPONSE: -3}"

    if [ "$HTTP_CODE" = "204" ]; then
        echo "✅ Client '${CLIENT_ID}' updated successfully"
        return 0
    else
        echo "❌ Failed to update client. HTTP Code: $HTTP_CODE"
        return 1
    fi
}

# Main execution
main() {
    echo "========================================="
    echo "🔧 Keycloak React PKCE Client Setup"
    echo "========================================="

    # Check Keycloak accessibility
    if ! check_keycloak; then
        exit 1
    fi

    # Get admin token
    if ! get_admin_token; then
        exit 1
    fi

    # Check if client exists and create/update accordingly
    if client_exists; then
        if ! update_client; then
            exit 1
        fi
    else
        if ! create_client; then
            exit 1
        fi
    fi

    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "📋 Client Configuration Summary:"
    echo "   - Client ID: ${CLIENT_ID}"
    echo "   - Client Type: Public (PKCE enabled)"
    echo "   - Redirect URI: http://localhost:3000/callback"
    echo "   - Post Logout URI: http://localhost:3000/"
    echo "   - Web Origins: http://localhost:3000"
    echo ""
    echo "🚀 You can now test the React authentication flow!"
    echo "   Open: http://localhost:3000"
}

# Run main function
main