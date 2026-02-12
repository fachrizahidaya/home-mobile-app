# Laravel Backend Implementation Guide for HomeSync

This guide will help you set up the required Laravel backend endpoints for the HomeSync Flutter app.

## Database Migration

First, create the users table modification or ensure you have these fields:

```php
// database/migrations/xxxx_xx_xx_create_users_table.php

Schema::create('users', function (Blueprint $table) {
    $table->id();
    $table->string('name');
    $table->string('username')->unique();
    $table->string('email')->unique();
    $table->timestamp('email_verified_at')->nullable();
    $table->string('password');
    $table->string('role')->default('member'); // member or admin
    $table->string('otp')->nullable();
    $table->timestamp('otp_expires_at')->nullable();
    $table->rememberToken();
    $table->timestamps();
});
```

Run migrations:

```bash
php artisan migrate
```

## User Model

Update your User model (`app/Models/User.php`):

```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
        'role',
        'otp',
        'otp_expires_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'otp',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'otp_expires_at' => 'datetime',
        'password' => 'hashed',
    ];
}
```

## Install Laravel Sanctum

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

## Authentication Controller

Create the controller:

```bash
php artisan make:controller Api/AuthController
```

Implement the controller (`app/Http/Controllers/Api/AuthController.php`):

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|min:2',
            'email' => 'required|email|unique:users,email',
            'username' => 'required|min:3|unique:users,username',
            'password' => 'required|min:8|confirmed',
            'role' => 'sometimes|in:member,admin',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Generate 6-digit OTP
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $user = User::create([
            'name' => $request->name,
            'username' => $request->username,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role ?? 'member',
            'otp' => Hash::make($otp),
            'otp_expires_at' => now()->addMinutes(10),
        ]);

        // Send OTP via email (will be logged since MAIL_MAILER=log)
        Mail::raw("Your OTP code is: {$otp}. Valid for 10 minutes.", function ($message) use ($user) {
            $message->to($user->email)
                    ->subject('Email Verification OTP');
        });

        return response()->json([
            'success' => true,
            'message' => 'Registration successful. OTP sent to your email.',
            'requires_otp' => true,
        ], 201);
    }

    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'otp' => 'required|digits:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        if (!$user->otp || !Hash::check($request->otp, $user->otp)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid OTP',
            ], 400);
        }

        if (now()->isAfter($user->otp_expires_at)) {
            return response()->json([
                'success' => false,
                'message' => 'OTP has expired',
            ], 400);
        }

        // Mark email as verified
        $user->email_verified_at = now();
        $user->otp = null;
        $user->otp_expires_at = null;
        $user->save();

        // Create token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Email verified successfully',
            'token' => $token,
            'data' => [
                'user' => $user,
            ],
        ]);
    }

    public function resendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found',
            ], 404);
        }

        // Generate new OTP
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $user->otp = Hash::make($otp);
        $user->otp_expires_at = now()->addMinutes(10);
        $user->save();

        // Send OTP via email
        Mail::raw("Your OTP code is: {$otp}. Valid for 10 minutes.", function ($message) use ($user) {
            $message->to($user->email)
                    ->subject('Email Verification OTP');
        });

        return response()->json([
            'success' => true,
            'message' => 'OTP sent successfully',
        ]);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials',
            ], 401);
        }

        // Check if email is verified
        if (!$user->email_verified_at) {
            // Generate and send new OTP
            $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

            $user->otp = Hash::make($otp);
            $user->otp_expires_at = now()->addMinutes(10);
            $user->save();

            Mail::raw("Your OTP code is: {$otp}. Valid for 10 minutes.", function ($message) use ($user) {
                $message->to($user->email)
                        ->subject('Email Verification OTP');
            });

            return response()->json([
                'success' => true,
                'message' => 'Please verify your email. OTP sent.',
                'requires_otp' => true,
            ]);
        }

        // Create token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'token' => $token,
            'data' => [
                'user' => $user,
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ]);
    }

    public function checkUsername(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'username' => 'required|min:3',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'available' => false,
            ]);
        }

        $exists = User::where('username', $request->username)->exists();

        return response()->json([
            'available' => !$exists,
        ]);
    }

    public function profile(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => [
                'user' => $request->user(),
            ],
        ]);
    }
}
```

## Routes Configuration

Add to `routes/api.php`:

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

// Public routes
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('/resend-otp', [AuthController::class, 'resendOtp']);
    Route::post('/check-username', [AuthController::class, 'checkUsername']);
});

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/user/profile', [AuthController::class, 'profile']);
});
```

## CORS Configuration

Update `config/cors.php` to allow Flutter app to communicate:

```php
return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'], // In production, specify your Flutter app's domain
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

## Testing the API

You can test the endpoints using curl or Postman:

### Register

```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "username": "testuser",
    "password": "Password123",
    "password_confirmation": "Password123"
  }'
```

### Check OTP in Laravel Logs

```bash
tail -f storage/logs/laravel.log
```

### Verify OTP

```bash
curl -X POST http://localhost:8000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "otp": "123456"
  }'
```

### Login

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Password123"
  }'
```

## Start Laravel Server

```bash
php artisan serve
```

The server will run on `http://localhost:8000`

## Notes

1. OTP codes will appear in `storage/logs/laravel.log` since MAIL_MAILER is set to `log`
2. OTPs expire after 10 minutes
3. For production, configure a proper mail driver (SMTP, Mailgun, etc.)
4. Consider adding rate limiting to prevent spam
5. Add proper validation and error handling
6. The `confirmed` validation rule on password automatically checks for matching `password_confirmation` field

## Next Steps

Once the Laravel backend is running:

1. Start the Flutter app
2. Register a new account
3. Check Laravel logs for the OTP
4. Verify the OTP in the app
5. Log in and test the member dashboard

## Security Considerations

For production:

- Use HTTPS
- Configure proper CORS origins
- Add rate limiting
- Implement proper password policies
- Use environment-specific configurations
- Add comprehensive logging and monitoring
