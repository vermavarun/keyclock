# Keycloak Client Configuration for PKCE

This document provides the exact configuration needed for your Keycloak client to work with the React PKCE application.

## 🔧 Correct Client Configuration

### Step 1: Access Keycloak Admin Console
```bash
# Ensure port-forward is running
kubectl port-forward -n keycloak svc/keycloak-service 8080:8080

# Open admin console
open http://localhost:8080/admin/
# Login: admin / admin123
```

### Step 2: Client Settings

Navigate to **Clients** → **react-pkce-client** (or create if it doesn't exist)

#### ✅ **General Settings**
```
Client ID: react-pkce-client
Name: react-pkce-client
Description: React PKCE Authentication Demo
Always display in UI: Off
```

#### ✅ **Access Settings**
```
Root URL: http://localhost:3000
Home URL: http://localhost:3000
Valid redirect URIs: http://localhost:3000/callback
Valid post logout redirect URIs: http://localhost:3000/
Web origins: http://localhost:3000
Admin URL: (leave empty)
```

#### ✅ **Capability Config** ⚠️ **IMPORTANT CHANGES**
```
Client authentication: OFF  ← This must be OFF for PKCE!
Authorization: OFF           ← This must be OFF for simple PKCE!
Authentication flow:
  ✅ Standard flow: ON
  ❌ Direct access grants: OFF
  ❌ Implicit flow: OFF
  ❌ Service accounts roles: OFF
  ❌ OAuth 2.0 Device Authorization Grant: OFF
  ❌ OIDC CIBA Grant: OFF
```

#### ✅ **Login Settings**
```
Login theme: (default)
Consent required: OFF
Display client on screen: OFF
Consent screen text: (empty)
```

#### ✅ **Logout Settings** ⚠️ **IMPORTANT CHANGES**
```
Front channel logout: OFF    ← Change this to OFF!
Front-channel logout URL: (empty)
Backchannel logout URL: (empty)
Backchannel logout session required: OFF
Backchannel logout revoke offline sessions: OFF
```

### Step 3: Advanced Settings

Navigate to **Advanced Settings** tab:

#### ✅ **Advanced Settings**
```
OAuth 2.0 Device Authorization Grant: OFF
Proof Key for Code Exchange Code Challenge Method: S256  ← Must be S256!
```

### Step 4: Save Configuration

Click **Save** after making all changes.

## 🔍 **Key Differences from Your Current Config**

### ❌ **Issues in Your Current Configuration:**
1. **Client authentication: ON** → Should be **OFF**
2. **Authorization: ON** → Should be **OFF**
3. **Front channel logout: ON** → Should be **OFF**

### ✅ **Why These Changes Are Needed:**

1. **Client Authentication OFF**:
   - PKCE is designed for public clients (no client secret)
   - Public clients cannot securely store secrets

2. **Authorization OFF**:
   - Simple PKCE flow doesn't need authorization policies
   - Keeps the configuration minimal and secure

3. **Front Channel Logout OFF**:
   - Prevents the `id_token_hint` requirement issue
   - Uses standard logout endpoint instead

## 🧪 **Test Your Configuration**

After making these changes:

1. **Start the React app:**
   ```bash
   cd react-keycloak-pkce
   npm start
   ```

2. **Test the flow:**
   - Visit http://localhost:3000
   - Click "Login with Keycloak"
   - Should redirect to Keycloak login
   - Login with admin/admin123 (or create a test user)
   - Should redirect back to profile page
   - Test logout - should work without errors

## 🔧 **If You Still Get Errors:**

### Error: "Missing parameters: id_token_hint"
- Ensure Front channel logout is **OFF**
- Clear browser cache and localStorage
- Restart the React app

### Error: "Invalid client or Invalid client credentials"
- Ensure Client authentication is **OFF**
- Check that Client ID matches exactly: `react-pkce-client`

### Error: "Invalid redirect URI"
- Ensure Valid redirect URIs is exactly: `http://localhost:3000/callback`
- No trailing slashes or extra characters

## 🎯 **Final Verification**

Your client configuration should look like this:

```
✅ Client authentication: OFF
✅ Authorization: OFF
✅ Standard flow: ON
✅ Front channel logout: OFF
✅ PKCE Code Challenge Method: S256
✅ Valid redirect URIs: http://localhost:3000/callback
```

Once configured correctly, the PKCE flow should work seamlessly! 🚀