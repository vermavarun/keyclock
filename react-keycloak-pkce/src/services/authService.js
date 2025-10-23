import CryptoJS from 'crypto-js';
import axios from 'axios';
import { keycloakConfig, pkceConfig } from '../config';

class AuthService {
  constructor() {
    this.tokenKey = 'keycloak_token';
    this.refreshTokenKey = 'keycloak_refresh_token';
    this.idTokenKey = 'keycloak_id_token';
    this.userInfoKey = 'keycloak_user_info';
    this.codeVerifierKey = 'pkce_code_verifier';
    this.stateKey = 'oauth_state';
  }

  // Generate random string for code verifier
  generateCodeVerifier() {
    const array = new Uint8Array(32);
    window.crypto.getRandomValues(array);
    return this.base64URLEncode(array);
  }

  // Generate code challenge from verifier
  async generateCodeChallenge(verifier) {
    const encoder = new TextEncoder();
    const data = encoder.encode(verifier);
    const digest = await window.crypto.subtle.digest('SHA-256', data);
    return this.base64URLEncode(new Uint8Array(digest));
  }

  // Base64 URL encode
  base64URLEncode(array) {
    return btoa(String.fromCharCode.apply(null, array))
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '');
  }

  // Generate random state
  generateState() {
    const array = new Uint8Array(16);
    window.crypto.getRandomValues(array);
    return this.base64URLEncode(array);
  }

  // Build authorization URL
  async buildAuthUrl() {
    const codeVerifier = this.generateCodeVerifier();
    const codeChallenge = await this.generateCodeChallenge(codeVerifier);
    const state = this.generateState();

    // Store in localStorage for later use
    localStorage.setItem(this.codeVerifierKey, codeVerifier);
    localStorage.setItem(this.stateKey, state);

    const params = new URLSearchParams({
      response_type: 'code',
      client_id: keycloakConfig.clientId,
      redirect_uri: keycloakConfig.redirectUri,
      scope: keycloakConfig.scope,
      code_challenge: codeChallenge,
      code_challenge_method: 'S256',
      state: state
    });

    return `${keycloakConfig.serverUrl}/realms/${keycloakConfig.realm}/protocol/openid-connect/auth?${params.toString()}`;
  }

  // Exchange authorization code for tokens
  async exchangeCodeForTokens(code, state) {
    const storedState = localStorage.getItem(this.stateKey);
    const codeVerifier = localStorage.getItem(this.codeVerifierKey);

    if (!storedState || state !== storedState) {
      throw new Error('Invalid state parameter');
    }

    if (!codeVerifier) {
      throw new Error('Code verifier not found');
    }

    const tokenUrl = `${keycloakConfig.serverUrl}/realms/${keycloakConfig.realm}/protocol/openid-connect/token`;

    const params = new URLSearchParams({
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: keycloakConfig.redirectUri,
      client_id: keycloakConfig.clientId,
      code_verifier: codeVerifier
    });

    try {
      const response = await axios.post(tokenUrl, params.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      });

      const { access_token, refresh_token, id_token } = response.data;

      console.log('Token exchange response:', {
        hasAccessToken: !!access_token,
        hasRefreshToken: !!refresh_token,
        hasIdToken: !!id_token,
        accessTokenLength: access_token ? access_token.length : 0,
        idTokenLength: id_token ? id_token.length : 0
      });

      // Store tokens
      localStorage.setItem(this.tokenKey, access_token);
      if (refresh_token) {
        localStorage.setItem(this.refreshTokenKey, refresh_token);
      }
      if (id_token) {
        localStorage.setItem(this.idTokenKey, id_token);
      } else {
        console.warn('No ID token received from Keycloak!');
      }

      // Clean up PKCE data
      localStorage.removeItem(this.codeVerifierKey);
      localStorage.removeItem(this.stateKey);

      // Fetch user info
      await this.fetchUserInfo(access_token);

      return { access_token, refresh_token, id_token };
    } catch (error) {
      console.error('Token exchange failed:', error);
      throw new Error('Failed to exchange authorization code for tokens');
    }
  }

  // Fetch user information
  async fetchUserInfo(accessToken) {
    const userInfoUrl = `${keycloakConfig.serverUrl}/realms/${keycloakConfig.realm}/protocol/openid-connect/userinfo`;

    try {
      const response = await axios.get(userInfoUrl, {
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      });

      localStorage.setItem(this.userInfoKey, JSON.stringify(response.data));
      return response.data;
    } catch (error) {
      console.error('Failed to fetch user info:', error);
      throw new Error('Failed to fetch user information');
    }
  }

  // Refresh access token
  async refreshToken() {
    const refreshToken = localStorage.getItem(this.refreshTokenKey);
    if (!refreshToken) {
      throw new Error('No refresh token available');
    }

    const tokenUrl = `${keycloakConfig.serverUrl}/realms/${keycloakConfig.realm}/protocol/openid-connect/token`;

    const params = new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
      client_id: keycloakConfig.clientId
    });

    try {
      const response = await axios.post(tokenUrl, params.toString(), {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      });

      const { access_token, refresh_token: newRefreshToken } = response.data;

      localStorage.setItem(this.tokenKey, access_token);
      if (newRefreshToken) {
        localStorage.setItem(this.refreshTokenKey, newRefreshToken);
      }

      return access_token;
    } catch (error) {
      console.error('Token refresh failed:', error);
      this.logout();
      throw new Error('Failed to refresh token');
    }
  }

  // Logout
  async logout() {
    const idToken = this.getIdToken();
    console.log('Logout - ID Token available:', !!idToken);
    console.log('ID Token length:', idToken ? idToken.length : 0);

    // Clear local storage
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.refreshTokenKey);
    localStorage.removeItem(this.idTokenKey);
    localStorage.removeItem(this.userInfoKey);
    localStorage.removeItem(this.codeVerifierKey);
    localStorage.removeItem(this.stateKey);

    // Simple logout without id_token_hint for now
    const logoutUrl = `${keycloakConfig.serverUrl}/realms/${keycloakConfig.realm}/protocol/openid-connect/logout?post_logout_redirect_uri=${encodeURIComponent(keycloakConfig.postLogoutRedirectUri)}`;

    // Always use simple logout to avoid id_token_hint issues
    console.log('Redirecting to:', logoutUrl);
    window.location.href = logoutUrl;
  }

  // Check if user is authenticated
  isAuthenticated() {
    const token = this.getAccessToken();
    if (!token) return false;

    try {
      // Decode JWT to check expiration
      const payload = JSON.parse(atob(token.split('.')[1]));
      const currentTime = Math.floor(Date.now() / 1000);
      return payload.exp > currentTime;
    } catch (error) {
      return false;
    }
  }

  // Get access token
  getAccessToken() {
    return localStorage.getItem(this.tokenKey);
  }

  // Get ID token
  getIdToken() {
    return localStorage.getItem(this.idTokenKey);
  }

  // Get user info
  getUserInfo() {
    const userInfo = localStorage.getItem(this.userInfoKey);
    return userInfo ? JSON.parse(userInfo) : null;
  }

  // Get authorization header
  getAuthHeader() {
    const token = this.getAccessToken();
    return token ? { Authorization: `Bearer ${token}` } : {};
  }

  // Axios interceptor for automatic token refresh
  setupAxiosInterceptors() {
    axios.interceptors.request.use(
      (config) => {
        const token = this.getAccessToken();
        if (token) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    axios.interceptors.response.use(
      (response) => response,
      async (error) => {
        if (error.response?.status === 401) {
          try {
            await this.refreshToken();
            // Retry the original request
            const originalRequest = error.config;
            const newToken = this.getAccessToken();
            originalRequest.headers.Authorization = `Bearer ${newToken}`;
            return axios(originalRequest);
          } catch (refreshError) {
            this.logout();
            return Promise.reject(refreshError);
          }
        }
        return Promise.reject(error);
      }
    );
  }
}

const authService = new AuthService();
export default authService;