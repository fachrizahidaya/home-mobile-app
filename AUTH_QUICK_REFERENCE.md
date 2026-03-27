# Quick Auth Reference

## Key Changes Made

### 1. AuthResponse Model

- Added `email` and `requiresVerification` fields
- Properly maps backend `requires_verification` field
- Extracts token from `data.access_token`

### 2. AuthService

- **register()** - Stores pending_email after registration
- **login()** - Handles both verified (token) and unverified (requires_verification) cases
- **verifyOtp()** - Validates OTP and creates authenticated session
- **resendOtp()** - Resends OTP to pending email

### 3. AuthProvider (State Management)

- New `AuthState` enum with `needsVerification` state
- New `LoginResult` class with `success`, `needsVerification`, `message` flags
- `login()` now returns `LoginResult` instead of bool
- `resendOtp()` uses internal `pendingEmail` (no parameter needed)
- Getters: `pendingEmail`, `needsVerification`

### 4. Screens Updated

- **LoginScreen** - Uses `LoginResult` to determine routing
- **RegisterScreen** - Already works (no changes needed)
- **OtpVerificationScreen** - Uses `authProvider.resendOtp()` without parameters

---

## Decision Tree: What Happens After Login

```
User clicks "Sign In"
       ↓
AuthProvider.login(email, password)
       ↓
    ┌──────────────────────────────────────┐
    │                                      │
API Returns success=true        API Returns success=false
(user is_verified=true)         (requires_verification=true)
    │                                      │
    ↓                                      ↓
loginResult.success = true      loginResult.needsVerification = true
pendingEmail cleared             pendingEmail stored
    │                                      │
    ↓                                      ↓
Navigate to                     Navigate to
MemberDashboardScreen           OtpVerificationScreen
(with token in header)          (verify via OTP)
```

---

## State Transitions

```
[Initial]
   ↓ (on app startup check token)
   ├─→ [Authenticated] (token exists)
   └─→ [Unauthenticated] (no token)

[Unauthenticated]
   ├─→ register() → [NeedsVerification]
   └─→ login() → [Authenticated] OR [NeedsVerification]

[NeedsVerification]
   ├─→ verifyOtp() → [Authenticated]
   └─→ resendOtp() → [NeedsVerification] (refresh OTP)

[Authenticated]
   └─→ logout() → [Unauthenticated]
```

---

## API Endpoints

| Endpoint               | Method | Purpose                     |
| ---------------------- | ------ | --------------------------- |
| `/auth/register`       | POST   | Create new account          |
| `/auth/verify-otp`     | POST   | Verify email with OTP       |
| `/auth/resend-otp`     | POST   | Resend OTP code             |
| `/auth/login`          | POST   | Sign in user                |
| `/auth/logout`         | POST   | Sign out user               |
| `/auth/check-username` | POST   | Check username availability |

---

## Common Tasks

### Check if user is logged in

```dart
if (authProvider.isAuthenticated) {
  // User has token
}
```

### Check if waiting for OTP

```dart
if (authProvider.needsVerification) {
  // Show OTP verification screen
}
```

### Access current user

```dart
final user = authProvider.user;
print(user?.email);
print(user?.role);
```

### Handle login with routing

```dart
final result = await authProvider.login(email, password);
if (result.success) {
  // Route to dashboard
} else if (result.needsVerification) {
  // Route to OTP screen
} else {
  // Show error: result.message
}
```

### Clear auth (logout)

```dart
await authProvider.logout();
// Navigate to login screen
```

---

## Token Flow

1. **After Login** (if verified)
   - Token saved to secure storage
   - Bearer token auto-added to all requests

2. **After Verify OTP**
   - Token saved to secure storage
   - User data saved

3. **On 401**
   - All storage cleared
   - User redirected to login

4. **On Logout**
   - Token revoked on backend
   - All storage cleared

---

## Debugging Tips

Enable prints to see state changes:

```dart
print('Auth State: ${authProvider.authState}');
print('Pending Email: ${authProvider.pendingEmail}');
print('User: ${authProvider.user?.email}');
print('Error: ${authProvider.errorMessage}');
```

Check persisted data:

```dart
final token = await storageService.getToken();
final user = await storageService.getUser();
final pendingEmail = await storageService.getString('pending_email');
```
