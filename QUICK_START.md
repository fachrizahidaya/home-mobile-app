# HomeSync - Quick Start Guide

## ✅ Project Setup Complete!

Your Flutter HomeSync app has been successfully created with the following features:

### 🎯 Implemented Features

1. **Authentication System**
   - ✅ User Registration with username validation
   - ✅ Real-time username availability check
   - ✅ Email & Password validation
   - ✅ 6-digit OTP verification via email
   - ✅ Role-based access (Member/Admin)
   - ✅ Secure token-based authentication

2. **User Interface**
   - ✅ Modern, clean UI with custom color scheme
   - ✅ Login Screen
   - ✅ Registration Screen
   - ✅ OTP Verification Screen
   - ✅ Member Dashboard
   - ✅ Splash Screen with auth check

3. **Dashboard Features**
   - ✅ Home tab with quick stats
   - ✅ Groceries management (placeholder)
   - ✅ Notes section (placeholder)
   - ✅ Home Tasks/Work section (placeholder)
   - ✅ User profile display
   - ✅ Logout functionality

## 🚀 How to Run

### Step 1: Configure API URL

Open `lib/core/constants/app_constants.dart` and update the base URL based on your setup:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

**For Physical Device:**
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000/api';
// Example: 'http://192.168.1.100:8000/api'
```

### Step 2: Set Up Laravel Backend

Follow the instructions in `LARAVEL_BACKEND_GUIDE.md` to set up your Laravel backend.

Key steps:
1. Update the User model and migration
2. Install Laravel Sanctum
3. Create the AuthController
4. Add API routes
5. Run `php artisan serve`

### Step 3: Run the Flutter App

```bash
# Make sure you're in the project directory
cd /Users/arifburhanthoyib/Documents/work/flutter_home_app/home_app

# Run the app
flutter run
```

## 📱 Testing the Authentication Flow

### Test Registration:

1. **Launch the app** - You'll see the Login screen
2. **Click "Sign Up"** to go to registration
3. **Fill in the form:**
   - Email: test@example.com
   - Username: testuser (will check availability in real-time)
   - Password: Test123456 (must meet requirements)
   - Confirm Password: Test123456
4. **Click "Sign Up"**
5. **Check Laravel logs** for OTP:
   ```bash
   # In your Laravel project directory
   tail -f storage/logs/laravel.log
   ```
6. **Enter the 6-digit OTP** from the logs
7. **You'll be logged in** and redirected to the Member Dashboard

### Test Login:

1. **Enter your email and password**
2. If email is verified, you'll be logged in directly
3. If not verified, OTP screen will appear

## 🗂️ Project Structure

```
lib/
├── core/
│   ├── constants/          # App-wide constants
│   └── utils/              # Utility functions
├── data/
│   ├── models/             # Data models
│   └── services/           # API & Storage services
├── providers/              # State management
├── presentation/
│   ├── screens/            # All screens
│   └── widgets/            # Reusable widgets
└── main.dart               # App entry point
```

## 🔑 Important Files

- **API Configuration:** `lib/core/constants/app_constants.dart`
- **Colors:** `lib/core/constants/app_colors.dart`
- **Auth Service:** `lib/data/services/auth_service.dart`
- **Auth Provider:** `lib/providers/auth_provider.dart`
- **Main Entry:** `lib/main.dart`

## 🎨 UI Components

### Custom Widgets Created:

1. **CustomButton** - Reusable button with loading state
2. **CustomTextField** - Form input with validation
3. **Member Dashboard** - Bottom navigation with 4 tabs

## 📋 API Endpoints Required

Your Laravel backend should implement:

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | Register new user |
| POST | /api/auth/login | Login user |
| POST | /api/auth/verify-otp | Verify OTP |
| POST | /api/auth/resend-otp | Resend OTP |
| POST | /api/auth/logout | Logout user |
| POST | /api/auth/check-username | Check username availability |
| GET | /api/user/profile | Get user profile |

## 🔒 Security Features

- ✅ Secure token storage using flutter_secure_storage
- ✅ Password validation (min 8 chars, uppercase, lowercase, number)
- ✅ Username validation (min 3 chars, alphanumeric + underscore)
- ✅ Email validation
- ✅ OTP expiration (10 minutes in Laravel)
- ✅ Token-based authentication

## 🎯 Next Steps

1. **Run the app** and test authentication
2. **Implement CRUD operations** for:
   - Groceries
   - Notes
   - Home Tasks
3. **Add Admin Dashboard** with different permissions
4. **Implement data synchronization**
5. **Add profile editing**

## 📚 Additional Documentation

- **SETUP_GUIDE.md** - Detailed setup instructions
- **LARAVEL_BACKEND_GUIDE.md** - Complete Laravel implementation

## 🐛 Troubleshooting

### Can't connect to API:
- Check if Laravel server is running: `php artisan serve`
- Verify the API base URL in app_constants.dart
- For Android Emulator, use 10.0.2.2 instead of localhost

### OTP not working:
- Check Laravel logs: `tail -f storage/logs/laravel.log`
- Verify OTP hasn't expired (10 minutes)
- Make sure email matches the registered email

### Build errors:
```bash
flutter clean
flutter pub get
flutter run
```

## 📞 Support

For detailed implementation guides, check:
- `SETUP_GUIDE.md` - Flutter app setup
- `LARAVEL_BACKEND_GUIDE.md` - Backend implementation

---

**Happy Coding! 🚀**

Your HomeSync app is ready to use. Start by running your Laravel backend and then launch the Flutter app to test the complete authentication flow.
