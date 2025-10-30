# Google OAuth Setup for Keycloak SSO

## Prerequisites
1. Google Cloud Console account
2. Running Keycloak instance

## Step 1: Create Google OAuth Client

### 1.1 Access Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable the **Google+ API** (if not already enabled)

### 1.2 Configure OAuth Consent Screen
1. Navigate to **APIs & Services** → **OAuth consent screen**
2. Choose **External** user type
3. Fill in required information:
   - **App name**: `Keycloak SSO Demo`
   - **User support email**: Your email
   - **Developer contact email**: Your email
4. Add scopes: `email`, `profile`, `openid`
5. Save and continue

### 1.3 Create OAuth Client Credentials
1. Navigate to **APIs & Services** → **Credentials**
2. Click **+ Create Credentials** → **OAuth 2.0 Client IDs**
3. Choose **Web application**
4. Configure:
   - **Name**: `Keycloak Google IdP`
   - **Authorized JavaScript origins**: `http://localhost:8081`
   - **Authorized redirect URIs**: `http://localhost:8081/realms/master/broker/google/endpoint`

### 1.4 Save Credentials
- Copy the **Client ID** and **Client Secret**
- You'll need these for Keycloak configuration

## Step 2: Configure Keycloak Identity Provider

### 2.1 Access Keycloak Admin Console
- URL: `http://localhost:8081/admin/`
- Login with admin credentials

### 2.2 Add Google Identity Provider
1. Go to **Identity Providers** in the left menu
2. Click **Add provider...** → **Google**
3. Configure the provider:
   - **Alias**: `google`
   - **Display Name**: `Sign in with Google`
   - **Client ID**: Paste your Google Client ID
   - **Client Secret**: Paste your Google Client Secret
   - **Default Scopes**: `openid profile email`

### 2.3 Advanced Settings (Optional)
- **Store Tokens**: ON (to store Google tokens)
- **Stored Tokens Readable**: ON (if you need to access Google APIs)
- **Trust Email**: ON (trust Google email verification)
- **Account Linking Only**: OFF (allow new user creation)

### 2.4 Save Configuration
Click **Save** to create the identity provider

## Step 3: Test Google SSO

### 3.1 Access Login Page
1. Go to your React app: `http://localhost:3000`
2. Click login - you should see Keycloak login page
3. You should now see **"Sign in with Google"** button

### 3.2 Test Authentication Flow
1. Click **"Sign in with Google"**
2. Complete Google OAuth flow
3. User should be redirected back to your app
4. Check Keycloak **Users** section - Google user should be created

## Step 4: User Management

### 4.1 Automatic User Creation
- Users authenticating via Google will be automatically created in Keycloak
- Email and basic profile info will be synced from Google

### 4.2 User Mapping
- Google users will have a linked account in Keycloak
- You can view this in **Users** → Select user → **Federated Identity**

## Troubleshooting

### Common Issues:
1. **Redirect URI mismatch**: Ensure Google OAuth redirect URI exactly matches Keycloak broker endpoint
2. **Scope issues**: Make sure Google project has proper API scopes enabled
3. **Email conflicts**: If local user exists with same email, linking may be required

### Debug Steps:
1. Check Keycloak logs for detailed error messages
2. Verify Google OAuth client configuration
3. Test with different Google accounts
4. Check browser network tab for failed requests