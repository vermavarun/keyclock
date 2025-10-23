// Keycloak configuration
export const keycloakConfig = {
  realm: 'master',
  clientId: 'react-pkce-client',
  serverUrl: 'http://localhost:8081',
  redirectUri: 'http://localhost:3000/callback',
  postLogoutRedirectUri: 'http://localhost:3000/',
  scope: 'openid profile email'
};

// PKCE configuration
export const pkceConfig = {
  codeChallenge: 'S256', // SHA256
  codeChallengeLength: 43, // Base64URL encoded SHA256 hash length
  state: 'random-state-string'
};