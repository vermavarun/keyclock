import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import authService from '../services/authService';
import './CallbackPage.css';

const CallbackPage = () => {
  const navigate = useNavigate();
  const [status, setStatus] = useState('processing');
  const [error, setError] = useState(null);

  useEffect(() => {
    const handleCallback = async () => {
      try {
        const urlParams = new URLSearchParams(window.location.search);
        const code = urlParams.get('code');
        const state = urlParams.get('state');
        const errorParam = urlParams.get('error');

        if (errorParam) {
          throw new Error(urlParams.get('error_description') || errorParam);
        }

        if (!code) {
          throw new Error('Authorization code not received');
        }

        setStatus('exchanging');
        await authService.exchangeCodeForTokens(code, state);

        setStatus('success');
        setTimeout(() => {
          navigate('/profile');
        }, 2000);

      } catch (error) {
        console.error('Callback handling failed:', error);
        setError(error.message);
        setStatus('error');
      }
    };

    handleCallback();
  }, [navigate]);

  const renderContent = () => {
    switch (status) {
      case 'processing':
        return (
          <>
            <div className="spinner"></div>
            <h2>Processing Authorization...</h2>
            <p>Please wait while we complete your login</p>
          </>
        );

      case 'exchanging':
        return (
          <>
            <div className="spinner"></div>
            <h2>Exchanging Tokens...</h2>
            <p>Securely exchanging authorization code for access tokens</p>
          </>
        );

      case 'success':
        return (
          <>
            <div className="success-icon">✅</div>
            <h2>Login Successful!</h2>
            <p>Redirecting to your profile...</p>
          </>
        );

      case 'error':
        return (
          <>
            <div className="error-icon">❌</div>
            <h2>Authentication Failed</h2>
            <p className="error-message">{error}</p>
            <button
              className="retry-button"
              onClick={() => navigate('/')}
            >
              Return to Login
            </button>
          </>
        );

      default:
        return null;
    }
  };

  return (
    <div className="callback-container">
      <div className="callback-card">
        {renderContent()}
      </div>
    </div>
  );
};

export default CallbackPage;