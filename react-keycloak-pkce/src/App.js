import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './components/LoginPage';
import CallbackPage from './components/CallbackPage';
import ProfilePage from './components/ProfilePage';
import ProtectedRoute from './components/ProtectedRoute';
import DebugPage from './components/DebugPage';
import authService from './services/authService';
import './App.css';

function App() {
  useEffect(() => {
    // Setup axios interceptors for automatic token handling
    authService.setupAxiosInterceptors();
  }, []);

  return (
    <Router>
      <div className="App">
        <Routes>
          <Route
            path="/"
            element={
              authService.isAuthenticated() ?
                <Navigate to="/profile" replace /> :
                <LoginPage />
            }
          />

          <Route path="/callback" element={<CallbackPage />} />

          <Route path="/debug" element={<DebugPage />} />

          <Route
            path="/profile"
            element={
              <ProtectedRoute>
                <ProfilePage />
              </ProtectedRoute>
            }
          />

          {/* Redirect any unknown routes to home */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;