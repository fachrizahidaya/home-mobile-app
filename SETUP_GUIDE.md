# HomeSync - Home Management App

A Flutter-based home management application with authentication connected to a Laravel PHP backend.

## Features

- ✅ User Registration with Username validation
- ✅ Email-based OTP verification (6-digit)
- ✅ Role-based authentication (Admin & Member)
- ✅ Member Dashboard with sections for:
  - Groceries Management
  - Notes
  - Home Tasks/Work
- ✅ Secure token-based authentication
- ✅ Beautiful and modern UI

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       # App color palette
│   │   └── app_constants.dart    # API endpoints & constants
│   └── utils/
│       └── validators.dart       # Form validation utilities
├── data/
│   ├── models/
│   │   ├── user_model.dart       # User data model
│   │   ├── auth_response.dart    # Auth response model
│   │   └── api_response.dart     # Generic API response
│   └── services/
│       ├── api_service.dart      # HTTP client service
│       ├── auth_service.dart     # Authentication service
│       └── storage_service.dart  # Local storage service
├── providers/
│   └── auth_provider.dart        # Authentication state management
├── presentation/
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── otp_verification_screen.dart
│   │   └── dashboard/
│   │       └── member_dashboard_screen.dart
│   └── widgets/
│       ├── custom_button.dart
│       └── custom_text_field.dart
└── main.dart                     # App entry point
```

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Laravel Backend running on localhost:8000
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Backend URL**
   
   Open `lib/core/constants/app_constants.dart` and update the base URL if needed:
   ```dart
   static const String baseUrl = 'http://localhost:8000/api';
   ```
   
   For Android Emulator, use: `http://10.0.2.2:8000/api`
   For iOS Simulator on Mac: `http://localhost:8000/api`
   For Physical Device: Use your computer's IP address (e.g., `http://192.168.1.100:8000/api`)

3. **Run the App**
   ```bash
   flutter run
   ```

## Laravel Backend Requirements

The app expects the following API endpoints from your Laravel backend:

### Authentication Endpoints

1. **Register** - `POST /api/auth/register`
   - Request: `{ name, email, password, password_confirmation, username, role }`
   - Response: `{ success, message, requires_otp }`

2. **Verify OTP** - `POST /api/auth/verify-otp`
   - Request: `{ email, otp }`
   - Response: `{ success, message, token, data: { user } }`

3. **Resend OTP** - `POST /api/auth/resend-otp`
   - Request: `{ email }`
   - Response: `{ success, message }`

4. **Login** - `POST /api/auth/login`
   - Request: `{ email, password }`
   - Response: `{ success, message, token, data: { user }, requires_otp? }`

5. **Logout** - `POST /api/auth/logout`
   - Headers: `Authorization: Bearer {token}`
   - Response: `{ success, message }`

6. **Check Username** - `POST /api/auth/check-username`
   - Request: `{ username }`
   - Response: `{ available: boolean }`

7. **User Profile** - `GET /api/user/profile`
   - Headers: `Authorization: Bearer {token}`
   - Response: `{ success, data: { user } }`

### Expected User Model Structure

```json
{
  "id": 1,
  "username": "johndoe",
  "email": "john@example.com",
  "role": "member",
  "email_verified_at": "2024-01-01T00:00:00.000000Z",
  "created_at": "2024-01-01T00:00:00.000000Z",
  "updated_at": "2024-01-01T00:00:00.000000Z"
}
```

## Usage Guide

### Registration Flow

1. User enters email, username, and password
2. App checks if username is available (real-time validation)
3. On successful registration, 6-digit OTP is sent to email
4. User enters OTP for verification
5. On successful verification, user is logged in and redirected to dashboard

### Login Flow

1. User enters email and password
2. If email not verified, OTP verification screen is shown
3. If verified, user is logged in directly
4. User is assigned 'member' role by default

### Member Dashboard

- **Home Tab**: Quick stats and recent activity
- **Groceries Tab**: Manage grocery items (placeholder for future implementation)
- **Notes Tab**: Create and manage notes (placeholder for future implementation)
- **Home Work Tab**: Manage home tasks (placeholder for future implementation)

## Dependencies

- `dio`: ^5.4.0 - HTTP client
- `provider`: ^6.1.1 - State management
- `shared_preferences`: ^2.2.2 - Local storage
- `flutter_secure_storage`: ^9.0.0 - Secure token storage
- `google_fonts`: ^6.1.0 - Custom fonts
- `email_validator`: ^2.1.17 - Email validation
- `pinput`: ^3.0.1 - OTP input field
- `flutter_spinkit`: ^5.2.0 - Loading indicators
- `fluttertoast`: ^8.2.4 - Toast messages

## Development Tips

### Testing with Android Emulator

If you're testing on Android Emulator, replace `localhost` with `10.0.2.2`:

```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

### Testing Email OTP

Since your Laravel mail driver is set to `log`, check the Laravel log file for OTP codes:
- Location: `storage/logs/laravel.log`
- Search for email messages containing the OTP

### Adding iOS Permissions

For iOS, add the following to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Adding Android Permissions

Internet permission is already included in Android manifest by default.

## Next Steps

This is a starter application with authentication. You can extend it by:

1. Implementing CRUD operations for:
   - Grocery items
   - Notes
   - Home tasks

2. Adding admin dashboard with different permissions

3. Implementing real-time synchronization

4. Adding profile management

5. Implementing family/household sharing features

## Troubleshooting

### Connection Issues

- Ensure Laravel backend is running on `http://localhost:8000`
- Check CORS configuration in Laravel
- Verify API endpoints match the expected structure

### Build Issues

- Run `flutter clean` and `flutter pub get`
- Check Flutter and Dart SDK versions
- Ensure all dependencies are compatible

## License

This project is created for educational purposes.

## Support

For issues and questions, please refer to:
- Flutter Documentation: https://docs.flutter.dev
- Laravel Documentation: https://laravel.com/docs
