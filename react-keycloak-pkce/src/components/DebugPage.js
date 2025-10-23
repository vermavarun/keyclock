import React from 'react';
import authService from '../services/authService';

const DebugPage = () => {
  const [debugInfo, setDebugInfo] = React.useState({});

  React.useEffect(() => {
    const checkAuth = () => {
      const isAuthenticated = authService.isAuthenticated();
      const accessToken = localStorage.getItem('keycloak_token');
      const idToken = localStorage.getItem('keycloak_id_token');
      const userInfo = localStorage.getItem('keycloak_user_info');

      setDebugInfo({
        isAuthenticated,
        hasAccessToken: !!accessToken,
        hasIdToken: !!idToken,
        hasUserInfo: !!userInfo,
        accessTokenLength: accessToken ? accessToken.length : 0,
        idTokenLength: idToken ? idToken.length : 0,
        userInfo: userInfo ? JSON.parse(userInfo) : null,
        localStorageKeys: Object.keys(localStorage).filter(key => key.includes('keycloak'))
      });
    };

    checkAuth();
  }, []);

  const handleTestLogin = () => {
    console.log('Starting debug login test...');
    authService.login();
  };

  const handleTestLogout = () => {
    console.log('Starting debug logout test...');
    authService.logout();
  };

  const handleClearStorage = () => {
    Object.keys(localStorage)
      .filter(key => key.includes('keycloak'))
      .forEach(key => localStorage.removeItem(key));

    window.location.reload();
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'monospace' }}>
      <h1>🔍 Authentication Debug Page</h1>

      <div style={{ marginBottom: '20px' }}>
        <button onClick={handleTestLogin} style={{ marginRight: '10px', padding: '10px' }}>
          🔑 Test Login
        </button>
        <button onClick={handleTestLogout} style={{ marginRight: '10px', padding: '10px' }}>
          🚪 Test Logout
        </button>
        <button onClick={handleClearStorage} style={{ padding: '10px' }}>
          🗑️ Clear Storage
        </button>
      </div>

      <div style={{ backgroundColor: '#f5f5f5', padding: '15px', borderRadius: '5px' }}>
        <h2>📊 Current Status</h2>
        <pre style={{ whiteSpace: 'pre-wrap' }}>
{JSON.stringify(debugInfo, null, 2)}
        </pre>
      </div>

      <div style={{ marginTop: '20px', backgroundColor: '#e8f4f8', padding: '15px', borderRadius: '5px' }}>
        <h3>💡 Instructions</h3>
        <ol>
          <li>Click "Test Login" to start the authentication flow</li>
          <li>Complete the login in Keycloak</li>
          <li>Return here to see the debug information</li>
          <li>Check browser console for detailed logs</li>
        </ol>
      </div>

      <div style={{ marginTop: '20px', backgroundColor: '#fff3cd', padding: '15px', borderRadius: '5px' }}>
        <h3>🔧 Expected Values</h3>
        <ul>
          <li><strong>isAuthenticated:</strong> true</li>
          <li><strong>hasAccessToken:</strong> true</li>
          <li><strong>hasIdToken:</strong> true</li>
          <li><strong>hasUserInfo:</strong> true</li>
          <li><strong>accessTokenLength:</strong> &gt; 500 characters</li>
          <li><strong>idTokenLength:</strong> &gt; 500 characters</li>
        </ul>
      </div>
    </div>
  );
};

export default DebugPage;