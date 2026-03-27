# Authentication & Authorization Flow

This document outlines the complete authentication and authorization system for HomeSync app, built to work seamlessly with the Laravel backend.

## Architecture Overview

The authentication system follows a clean layered architecture:

```
UI Layer (Screens)
       ↓
Provider Layer (AuthProvider)
       ↓
Service Layer (AuthService)
       ↓
API Layer (ApiService)
       ↓
Storage Layer (StorageService)
```

## Components

### 1. **AuthResponse Model** (`lib/data/models/auth_response.dart`)

Handles all API responses with fields:

- `success` - Whether operation was successful
- `message` - Response message from backend
- `token` - JWT access token (if authenticated)
- `data` - Additional data (user info, etc.)
- `email` - Email field (for verification flows)
- `requiresVerification` - Whether user needs OTP verification

### 2. **AuthService** (`lib/data/services/auth_service.dart`)

Direct API integration layer that:

- Makes HTTP requests to backend endpoints
- Parses responses into `AuthResponse` objects
- Stores/retrieves tokens and user data
- Handles three main flows:
  - **Register** → Sends OTP
  - **Login** → Token or needs verification
  - **Verify OTP** → Creates token

### 3. **AuthProvider** (`lib/providers/auth_provider.dart`)

Business logic layer that:

- Manages authentication state using `AuthState` enum
- Handles registration, login, OTP verification, logout
- Stores pending email for verification flows
- Updates UI consumers

**AuthState Values:**

- `initial` - App startup
- `authenticated` - User logged in with token
- `needsVerification` - User registered/login but needs OTP
- `unauthenticated` - No active session
- `loading` - Operation in progress

### 4. **StorageService** (`lib/data/services/storage_service.dart`)

Persistent storage:

- **Secure Storage** - JWT token (sensitive)
- **Shared Preferences** - User data, pending email (non-sensitive)

### 5. **ApiService** (`lib/data/services/api_service.dart`)

HTTP client configuration:

- Automatically adds `Authorization: Bearer $token` header
- Handles 401 responses by clearing storage
- Centralized error handling

## Complete Auth Flows

### Flow 1: User Registration

```
RegisterScreen → AuthProvider.register()
       ↓
AuthService.register()
       ↓
POST /auth/register
       ↓
Backend: Returns success=true, sends OTP to email
       ↓
Store pending_email in storage
       ↓
Navigate to OtpVerificationScreen
```

**Backend Response:**

```json
{
  "success": true,
  "message": "Registration successful. Please check your email...",
  "data": {
    "user_id": 20,
    "email": "user@example.com",
    "username": "username"
  }
}
```

### Flow 2: OTP Verification (Registration)

```
OtpVerificationScreen → AuthProvider.verifyOtp()
       ↓
AuthService.verifyOtp()
       ↓
POST /auth/verify-otp
       ↓
Backend: Returns success=true, token, user data
       ↓
Save token to secure storage
Save user data to shared preferences
Clear pending_email
Set authState = authenticated
       ↓
Navigate to MemberDashboardScreen
```

**Backend Response:**

```json
{
  "success": true,
  "message": "Email verified successfully",
  "data": {
    "user": {
      "id": 20,
      "name": "John Doe",
      "username": "username",
      "email": "user@example.com",
      "role": "member"
    },
    "token": "70|uj3YO4MjtJe7OQTZ...",
    "token_type": "Bearer",
    "expires_at": "2026-03-25T05:49:36.000000Z",
    "expires_in": 3600
  }
}
```

### Flow 3: User Login (Already Verified)

```
LoginScreen → AuthProvider.login()
       ↓
AuthService.login()
       ↓
POST /auth/login
       ↓
Backend: User is verified → Returns success=true, token, user data
       ↓
Save token to secure storage
Save user data to shared preferences
Set authState = authenticated
Return: LoginResult(success: true)
       ↓
Navigate to MemberDashboardScreen
```

**Backend Response:**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 20,
      "name": "John Doe",
      "email": "user@example.com",
      "role": "member",
      "is_verified": true
    },
    "access_token": "70|uj3YO4MjtJe7OQTZ...",
    "token_type": "Bearer",
    "expires_at": "2026-03-25T05:49:36.000000Z",
    "expires_in": 3600
  }
}
```

### Flow 4: User Login (Not Verified)

```
LoginScreen → AuthProvider.login()
       ↓
AuthService.login()
       ↓
POST /auth/login
       ↓
Backend: User exists but NOT verified:
Returns success=false, requires_verification=true
       ↓
Store pending_email in storage
Set authState = needsVerification
Return: LoginResult(success: false, needsVerification: true)
       ↓
Navigate to OtpVerificationScreen
```

**Backend Response:**

```json
{
  "success": false,
  "message": "Your account is not verified. A new OTP has been sent to your email.",
  "requires_verification": true,
  "email": "user@example.com"
}
```

### Flow 5: Logout

```
UI → AuthProvider.logout()
       ↓
AuthService.logout()
       ↓
POST /auth/logout (to revoke token on backend)
       ↓
Clear all storage (token, user data, pending email)
Set authState = unauthenticated
       ↓
Navigate to LoginScreen
```

## Usage in Screens

### LoginScreen

```dart
final result = await authProvider.login(
  email: email,
  password: password,
);

if (result.success) {
  // Navigate to dashboard
} else if (result.needsVerification) {
  // Navigate to OTP verification
} else {
  // Show error
}
```

### RegisterScreen

```dart
final success = await authProvider.register(
  name: name,
  email: email,
  password: password,
  passwordConfirmation: passwordConfirmation,
  username: username,
);

if (success) {
  // Navigate to OTP verification screen
  // Use authProvider.pendingEmail to get the email
}
```

### OTP Verification Screen

```dart
final success = await authProvider.verifyOtp(
  email: email,
  otp: otp,
);

if (success) {
  // Navigate to dashboard
}

// Resend OTP
final resendSuccess = await authProvider.resendOtp();
```

## Token Management

### Automatic Token Injection

The `ApiService` automatically adds the token to all requests:

```dart
if (token != null) {
  options.headers['Authorization'] = 'Bearer $token';
}
```

### Token Revocation

On 401 Unauthorized response, all storage is cleared and user can re-login.

### Token Refresh

Implement endpoint: `POST /auth/refresh-token` when needed

## State Model

### AuthState Enum

```dart
enum AuthState {
  initial,           // App startup
  authenticated,     // Logged in with token
  needsVerification, // Needs OTP verification
  unauthenticated,   // Not logged in
  loading,          // Operation in progress
}
```

### AuthProvider Getters

```dart
authProvider.isAuthenticated    // bool - true if logged in
authProvider.needsVerification  // bool - true if needs OTP
authProvider.isLoading          // bool - operation in progress
authProvider.authState          // AuthState - current state
authProvider.user               // User? - current user
authProvider.errorMessage       // String? - last error
authProvider.pendingEmail       // String? - email waiting for verification
```

## Integration with Main App

### App Initialization

```dart
future: authProvider.initializeAuth(),
builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return SplashScreen();
  }

  return authProvider.isAuthenticated
    ? DashboardScreen()
    : LoginScreen();
}
```

### Route Navigation

After authentication changes, navigate using:

- Named routes: `Navigator.pushReplacementNamed(context, '/dashboard')`
- Or use the state to conditionally build different screens

## Error Handling

All errors from the backend are captured in:

- `authProvider.errorMessage` - User-friendly error message
- Backend response status codes determine routing:
  - `200` - Success
  - `401` - Unauthorized (cleared auth)
  - `403` - Forbidden (needs verification)
  - `422` - Validation error
  - `429` - Rate limited (OTP spam)

## Security Considerations

✅ **Implemented:**

- JWT tokens stored in secure storage
- Automatic token injection in headers
- Token revocation on logout
- 401 handling clears auth state
- User data encrypted in storage

⚠️ **To Implement:**

- Token refresh before expiration
- Rate limiting on auth endpoints
- HTTPS only in production
- Add pinning for certificate security
