# React Keycloak PKCE Authentication Demo

A modern React application demonstrating secure authentication using **OAuth 2.0 Authorization Code Flow with PKCE** (Proof Key for Code Exchange) integrated with Keycloak.

## 🚀 Features

- **🔐 PKCE Security**: Implements OAuth 2.0 PKCE flow for enhanced security
- **🔄 Auto Token Refresh**: Automatic access token refresh using refresh tokens
- **🛡️ Protected Routes**: Route protection with authentication guards
- **👤 User Profile**: Display user information from Keycloak
- **📱 Responsive Design**: Modern, mobile-friendly UI
- **⚡ Real-time Status**: Live authentication status indicators

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React App     │    │   Keycloak      │    │   User Browser  │
│                 │    │   Server        │    │                 │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • LoginPage     │◄───┤ • OAuth2/OIDC   │◄───┤ • Authentication│
│ • CallbackPage  │    │ • PKCE Support  │    │ • Consent       │
│ • ProfilePage   │    │ • Token Service │    │ • Session       │
│ • AuthService   │    │ • User Info     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │ PKCE Flow Steps │
                    ├─────────────────┤
                    │ 1. Code Verifier│
                    │ 2. Code Challenge│
                    │ 3. Authorization│
                    │ 4. Token Exchange│
                    │ 5. User Info    │
                    └─────────────────┘
```

## 🔧 Prerequisites

Before running this application, ensure you have:

1. **Node.js** (v16 or higher)
2. **npm** or **yarn**
3. **Keycloak server** running (from the parent directory)
4. **Keycloak client configured** (see setup below)

## ⚙️ Keycloak Client Setup

### 1. Access Keycloak Admin Console

```bash
# From the parent directory, start port-forwarding
kubectl port-forward -n keycloak svc/keycloak-service 8080:8080

# Open admin console
open http://localhost:8080/admin/
```

**Login credentials:**
- Username: `admin`
- Password: `admin123`

### 2. Create a New Client

1. Navigate to **Clients** → **Create Client**
2. **Client type**: `OpenID Connect`
3. **Client ID**: `react-pkce-client`
4. Click **Next**

### 3. Configure Client Settings

**Capability config:**
- ✅ **Client authentication**: OFF (Public client)
- ✅ **Authorization**: OFF
- ✅ **Standard flow**: ON
- ✅ **Direct access grants**: OFF
- ✅ **Implicit flow**: OFF
- ✅ **Service accounts roles**: OFF

**Login settings:**
- **Root URL**: `http://localhost:3000`
- **Home URL**: `http://localhost:3000`
- **Valid redirect URIs**: `http://localhost:3000/callback`
- **Valid post logout redirect URIs**: `http://localhost:3000/`
- **Web origins**: `http://localhost:3000`

### 4. Advanced Settings

Navigate to **Advanced** tab and configure:
- **Proof Key for Code Exchange Code Challenge Method**: `S256`
- **OAuth 2.0 Device Authorization Grant**: OFF

Click **Save**

## 🚀 Getting Started

### 1. Install Dependencies

```bash
cd react-keycloak-pkce
npm install
```

### 2. Configure Application

The configuration is already set in `src/config.js`. Verify the settings match your Keycloak setup:

```javascript
export const keycloakConfig = {
  realm: 'master',
  clientId: 'react-pkce-client',
  serverUrl: 'http://localhost:8080',
  redirectUri: 'http://localhost:3000/callback',
  postLogoutRedirectUri: 'http://localhost:3000/',
  scope: 'openid profile email'
};
```

### 3. Start the Application

```bash
npm start
```

The app will be available at `http://localhost:3000`

## 🔄 PKCE Flow Implementation

### Flow Steps

1. **Code Verifier Generation**: Random cryptographic string
2. **Code Challenge Creation**: SHA256 hash of code verifier (Base64URL encoded)
3. **Authorization Request**: Redirect to Keycloak with PKCE parameters
4. **Authorization Code Exchange**: Exchange code + verifier for tokens
5. **Token Storage**: Secure storage in localStorage
6. **Automatic Refresh**: Token refresh before expiration

### Security Features

- **No Client Secret**: Public client with PKCE eliminates secret exposure
- **State Parameter**: CSRF protection with random state validation
- **Code Verifier**: Cryptographically random 43-character string
- **SHA256 Challenge**: Code challenge prevents code interception attacks
- **Automatic Logout**: Token expiration handling with automatic logout

## 📁 Project Structure

```
react-keycloak-pkce/
├── public/
│   └── index.html              # Main HTML template
├── src/
│   ├── components/
│   │   ├── LoginPage.js        # Login interface
│   │   ├── LoginPage.css       # Login styles
│   │   ├── CallbackPage.js     # OAuth callback handler
│   │   ├── CallbackPage.css    # Callback styles
│   │   ├── ProfilePage.js      # User profile display
│   │   ├── ProfilePage.css     # Profile styles
│   │   └── ProtectedRoute.js   # Route protection
│   ├── services/
│   │   └── authService.js      # PKCE authentication logic
│   ├── config.js               # Keycloak configuration
│   ├── App.js                  # Main application
│   ├── App.css                 # App styles
│   ├── index.js               # React entry point
│   └── index.css              # Global styles
├── package.json               # Dependencies and scripts
└── README.md                  # This file
```

## 🔐 Authentication Service API

### Key Methods

```javascript
// Login flow
const authUrl = await authService.buildAuthUrl();
window.location.href = authUrl;

// Handle callback
await authService.exchangeCodeForTokens(code, state);

// Check authentication
const isAuth = authService.isAuthenticated();

// Get user info
const user = authService.getUserInfo();

// Refresh token
await authService.refreshToken();

// Logout
authService.logout();
```

## 🎯 Usage Examples

### 1. Login Process

1. Click **"Login with Keycloak"** on the home page
2. Redirect to Keycloak authentication
3. Enter credentials (use Keycloak admin or create a user)
4. Automatic redirect back to `/callback`
5. Token exchange and redirect to `/profile`

### 2. Protected Resources

```javascript
// Making authenticated API calls
const headers = authService.getAuthHeader();
const response = await axios.get('/api/protected-resource', { headers });
```

### 3. Token Management

The service automatically handles:
- Token storage in localStorage
- Token expiration checking
- Automatic token refresh
- Logout on refresh failure

## 🎨 UI Components

### LoginPage
- Modern gradient background
- Feature highlights
- Secure login button
- Responsive design

### CallbackPage
- Loading states
- Progress indicators
- Error handling
- Success feedback

### ProfilePage
- User information display
- Token status indicator
- Action buttons (refresh/logout)
- Security feature highlights

## 🔧 Troubleshooting

### Common Issues

#### 1. **CORS Errors**
```bash
# Ensure Keycloak web origins include: http://localhost:3000
```

#### 2. **Invalid Client Configuration**
```bash
# Verify client ID matches config.js
# Ensure redirect URI is exactly: http://localhost:3000/callback
```

#### 3. **Token Exchange Fails**
```bash
# Check PKCE is enabled in client settings
# Verify Code Challenge Method is set to S256
```

#### 4. **Redirect Loop**
```bash
# Clear localStorage: localStorage.clear()
# Check valid redirect URIs in Keycloak client
```

### Debug Mode

Enable debug logging:
```javascript
// In browser console
localStorage.setItem('debug', 'true');
```

## 🚀 Production Deployment

### Environment Variables

Create `.env` file:
```env
REACT_APP_KEYCLOAK_URL=https://your-keycloak-domain.com
REACT_APP_KEYCLOAK_REALM=your-realm
REACT_APP_KEYCLOAK_CLIENT_ID=your-client-id
REACT_APP_REDIRECT_URI=https://your-app-domain.com/callback
```

### Build for Production

```bash
npm run build
```

### Security Considerations

- Use HTTPS in production
- Configure proper CSP headers
- Set secure cookie attributes
- Implement proper CORS policies
- Use environment-specific configurations

## 📚 Additional Resources

- [OAuth 2.0 PKCE RFC](https://tools.ietf.org/html/rfc7636)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [OIDC Specification](https://openid.net/connect/)
- [React Router Documentation](https://reactrouter.com/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🎉 Demo Features

### 🔒 Authentication Flow
- **Secure PKCE**: Industry-standard security for SPAs
- **State Validation**: CSRF protection
- **Token Management**: Automatic refresh and secure storage

### 👤 User Experience
- **Modern UI**: Beautiful, responsive interface
- **Real-time Feedback**: Loading states and progress indicators
- **Error Handling**: Graceful error management

### 🛡️ Security Features
- **No Secrets**: Public client with PKCE
- **Secure Storage**: Proper token handling
- **Auto Logout**: Session management

**Ready to explore secure authentication with Keycloak and React!** 🚀