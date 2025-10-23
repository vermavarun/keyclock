# Keycloak Client Creation Guide

## Create React PKCE Client in Keycloak

### Step 1: Access Keycloak Admin Console
- URL: http://localhost:8081
- Username: `admin`
- Password: `admin123`

### Step 2: Create New Client
1. Go to **Clients** in left menu
2. Click **Create client** button
3. Fill in the form:

**General Settings:**
- Client type: `OpenID Connect`
- Client ID: `react-pkce-client`
- Name: `React PKCE Client`
- Description: `React app using PKCE authentication flow`

Click **Next**

**Capability config:**
- Client authentication: `OFF` ⚠️ **Critical for PKCE**
- Authorization: `OFF`
- Authentication flow:
  - ✅ Standard flow
  - ✅ Direct access grants
  - ❌ Implicit flow
  - ❌ Service accounts roles

Click **Next**

**Login settings:**
- Root URL: `http://localhost:3000`
- Home URL: `http://localhost:3000`
- Valid redirect URIs: `http://localhost:3000/callback`
- Valid post logout redirect URIs: `http://localhost:3000/`
- Web origins: `http://localhost:3000`

Click **Save**

### Step 3: Advanced Settings (Optional)
Go to **Advanced** tab and verify:
- Proof Key for Code Exchange Code Challenge Method: `S256`

### Step 4: Test Authentication
After creating the client, go back to your React app and test the login flow.