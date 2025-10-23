import React, { useState, useEffect } from 'react';
import authService from '../services/authService';
import './ProfilePage.css';

const ProfilePage = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadUserInfo = () => {
      try {
        const userInfo = authService.getUserInfo();
        setUser(userInfo);
      } catch (error) {
        console.error('Failed to load user info:', error);
      } finally {
        setLoading(false);
      }
    };

    loadUserInfo();
  }, []);

  const handleLogout = () => {
    authService.logout();
  };

  const handleRefreshToken = async () => {
    try {
      await authService.refreshToken();
      alert('Token refreshed successfully!');
    } catch (error) {
      alert('Token refresh failed: ' + error.message);
    }
  };

  if (loading) {
    return (
      <div className="profile-container">
        <div className="profile-card">
          <div className="spinner"></div>
          <p>Loading profile...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="profile-container">
      <div className="profile-card">
        <div className="profile-header">
          <div className="avatar">
            {user?.name ? user.name.charAt(0).toUpperCase() : '👤'}
          </div>
          <h1>Welcome, {user?.name || user?.preferred_username || 'User'}!</h1>
          <p className="profile-subtitle">Your PKCE authentication was successful</p>
        </div>

        <div className="profile-content">
          <div className="user-info">
            <h3>📋 Profile Information</h3>
            <div className="info-grid">
              <div className="info-item">
                <span className="info-label">Name:</span>
                <span className="info-value">{user?.name || 'N/A'}</span>
              </div>
              <div className="info-item">
                <span className="info-label">Username:</span>
                <span className="info-value">{user?.preferred_username || 'N/A'}</span>
              </div>
              <div className="info-item">
                <span className="info-label">Email:</span>
                <span className="info-value">{user?.email || 'N/A'}</span>
              </div>
              <div className="info-item">
                <span className="info-label">Email Verified:</span>
                <span className={`info-value ${user?.email_verified ? 'verified' : 'unverified'}`}>
                  {user?.email_verified ? '✅ Yes' : '❌ No'}
                </span>
              </div>
              <div className="info-item">
                <span className="info-label">Subject ID:</span>
                <span className="info-value subject-id">{user?.sub || 'N/A'}</span>
              </div>
            </div>
          </div>

          <div className="token-info">
            <h3>🔐 Token Information</h3>
            <div className="token-status">
              <span className="status-indicator active"></span>
              <span>Access token is active</span>
            </div>
            <p className="token-note">
              Your session is secured with OAuth 2.0 PKCE flow.
              The access token will be automatically refreshed when needed.
            </p>
          </div>

          <div className="actions">
            <button
              className="action-button refresh-button"
              onClick={handleRefreshToken}
            >
              <span className="button-icon">🔄</span>
              Refresh Token
            </button>

            <button
              className="action-button logout-button"
              onClick={handleLogout}
            >
              <span className="button-icon">🚪</span>
              Logout
            </button>
          </div>
        </div>

        <div className="security-info">
          <h3>🛡️ Security Features</h3>
          <div className="security-grid">
            <div className="security-item">
              <span className="security-icon">🔒</span>
              <span>PKCE Flow</span>
            </div>
            <div className="security-item">
              <span className="security-icon">🔄</span>
              <span>Auto Refresh</span>
            </div>
            <div className="security-item">
              <span className="security-icon">🛡️</span>
              <span>Secure Storage</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfilePage;