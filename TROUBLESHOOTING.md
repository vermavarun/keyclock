# Keycloak Client Configuration Troubleshooting

## Current Issue: Missing ID Token

The "Missing parameters: id_token_hint" error during logout typically occurs when:
1. The ID token wasn't received during the initial authentication
2. The Keycloak client is not configured correctly

## Required Keycloak Client Settings

Please verify these settings in your Keycloak Admin Console:

### 1. Access Keycloak Admin Console
```bash
# Forward the Keycloak service (if using K8s deployment)
kubectl port-forward -n keycloak svc/keycloak 8081:8080

# Open browser to: http://localhost:8081
# Login with admin credentials
```

### 2. Navigate to Client Configuration
1. Go to **Clients** in the left menu
2. Find your client: `react-pkce-client`
3. Click on it to open settings

### 3. Verify General Settings
- **Client Type**: `OpenID Connect`
- **Client ID**: `react-pkce-client`
- **Name**: `React PKCE Client` (optional)
- **Description**: `React app using PKCE flow` (optional)

### 4. Verify Access Settings
- **Root URL**: `http://localhost:3000`
- **Home URL**: `http://localhost:3000`
- **Valid redirect URIs**: `http://localhost:3000/callback`
- **Valid post logout redirect URIs**: `http://localhost:3000/`
- **Web origins**: `http://localhost:3000`

### 5. Verify Capability Config
- **Client authentication**: `OFF` (This makes it a public client)
- **Authorization**: `OFF`
- **Authentication flow**:
  - ✅ Standard flow
  - ✅ Direct access grants
  - ✅ Implicit flow (can be OFF)
  - ✅ Service accounts roles (can be OFF)
  - ✅ OAuth 2.0 Device Authorization Grant (can be OFF)
  - ✅ OIDC CIBA Grant (can be OFF)

### 6. Advanced Settings (if available)
- **Proof Key for Code Exchange Code Challenge Method**: `S256`
- **OAuth 2.0 Mutual TLS Certificate Bound Access Tokens Enabled**: `OFF`
- **OAuth 2.0 Pushed Authorization Requests**: `OFF`

## Testing Steps

1. **Test the authentication flow with debugging**:
   ```bash
   cd /Users/varun.verma/Desktop/Code/_github_vermavarun/keyclock/react-keycloak-pkce
   npm start
   ```

2. **Open browser console** and watch for these debug messages:
   - `Starting authentication...`
   - `Token exchange response:` - Check if `hasIdToken: true`
   - `Logout process:` - Check if ID token is found

3. **Check the token exchange response**:
   - If `hasIdToken: false`, the client configuration needs to be updated
   - If `hasIdToken: true` but logout still fails, there might be a token storage issue

## Common Issues and Solutions

### Issue 1: No ID Token Received
**Solution**: Ensure the client has `openid` scope and is configured as a public client.

### Issue 2: Client Authentication Issues
**Solution**: Make sure "Client authentication" is set to `OFF` for PKCE flow.

### Issue 3: Redirect URI Mismatch
**Solution**: Ensure all redirect URIs exactly match your app URLs.

## Debugging Commands

If you're still having issues, you can test the Keycloak endpoints directly:

```bash
# Test the authorization endpoint
curl -v "http://localhost:8081/realms/master/protocol/openid-connect/auth?client_id=react-pkce-client&response_type=code&scope=openid%20profile%20email&redirect_uri=http://localhost:3000/callback&state=test-state&code_challenge=test-challenge&code_challenge_method=S256"

# Check Keycloak well-known configuration
curl http://localhost:8081/realms/master/.well-known/openid_configuration
```

## Next Steps

1. Verify all the above settings in Keycloak Admin Console
2. Restart your React app
3. Check the browser console for debug messages during login
4. If ID token is still missing, create a new client with the correct settings