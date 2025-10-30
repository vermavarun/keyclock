import React from 'react';
import authService from '../services/authService';
import './LoginPage.css';

const LoginPage = () => {
  const handleLogin = async () => {
    try {
      const authUrl = await authService.buildAuthUrl();
      window.location.href = authUrl;
    } catch (error) {
      console.error('Login failed:', error);
      alert('Login failed. Please try again.');
    }
  };

  const handleGoogleLogin = async () => {
    try {
      const authUrl = await authService.buildAuthUrl('google');
      window.location.href = authUrl;
    } catch (error) {
      console.error('Google login failed:', error);
      alert('Google login failed. Please try again.');
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-header">
          <h1>🔐 Keycloak PKCE Demo</h1>
          <p>Secure authentication with PKCE flow</p>
        </div>

        <div className="login-content">
          <div className="feature-list">
            <div className="feature">
              <span className="feature-icon">🛡️</span>
              <span>PKCE Security</span>
            </div>
            <div className="feature">
              <span className="feature-icon">🔄</span>
              <span>Auto Token Refresh</span>
            </div>
            <div className="feature">
              <span className="feature-icon">👤</span>
              <span>User Profile</span>
            </div>
          </div>

          <div className="login-buttons">
            <button
              className="login-button keycloak-button"
              onClick={handleLogin}
            >
              <span className="button-icon">🚀</span>
              Login with Keycloak
            </button>

            <div className="divider">
              <span className="divider-text">or</span>
            </div>

            <button
              className="login-button google-button"
              onClick={handleGoogleLogin}
            >
              <span className="button-icon">🔍</span>
              Sign in with Google
            </button>
          </div>

          <div className="info-section">
            <p className="info-text">
              This demo implements OAuth 2.0 Authorization Code flow with PKCE
              (Proof Key for Code Exchange) for enhanced security in single-page applications.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;