# 🚨 Google OAuth Redirect URI Fix

## ❌ **Error Explanation**
The error `redirect_uri_mismatch` means the redirect URI in your Google Cloud Console doesn't match what Keycloak is sending.

## ✅ **Quick Fix Steps**

### 1. **Correct Redirect URI**
Go to your [Google Cloud Console](https://console.cloud.google.com/) and update the **Authorized redirect URI** to:

```
http://localhost:8081/realms/master/broker/google/endpoint
```

### 2. **Where to Update**
1. Go to **APIs & Services** → **Credentials**
2. Click on your OAuth 2.0 Client ID
3. In **Authorized redirect URIs** section, add/update:
   ```
   http://localhost:8081/realms/master/broker/google/endpoint
   ```
4. Click **Save**

### 3. **Common Mistakes**
❌ `http://localhost:3000/callback` (This is for React app, not Google OAuth)
❌ `http://localhost:8080/...` (Wrong port - should be 8081)
❌ Missing `/broker/google/endpoint` (This is Keycloak's Google IdP endpoint)

✅ **CORRECT**: `http://localhost:8081/realms/master/broker/google/endpoint`

## 🔄 **Complete Flow Explanation**

```
React App (3000)
    ↓ (User clicks "Sign in with Google")
Keycloak (8081)
    ↓ (Redirects to Google with correct URI)
Google OAuth
    ↓ (Returns to Keycloak endpoint)
Keycloak (8081/realms/master/broker/google/endpoint)
    ↓ (Processes Google response, creates session)
React App (3000/callback)
    ↓ (Gets authorization code)
User Dashboard
```

## 🛠️ **After Fixing**

1. Save the changes in Google Console
2. Wait 5-10 minutes for changes to propagate
3. Test again: http://localhost:3000 → "Sign in with Google"

The redirect URI mismatch should be resolved! 🎉