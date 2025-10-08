# Testing Guide - Authentication Feature

## Phase 2-1: Login Feature Testing

### Prerequisites

1. **Base URL Configuration**
   - The app needs a valid manga site URL
   - This should be configured in Settings before testing login

### Test Flow

#### 1. Initial Setup

```bash
# Make sure all dependencies are installed
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

#### 2. Configure Base URL

1. App opens on Home page
2. Click "설정 (Settings)" button
3. Enter Base URL (e.g., `https://example.com`)
4. Click "설정 저장 (Save Settings)"
5. Navigate back to Home

#### 3. Test Login Flow

1. From Home page, click "로그인 (Login)" button
2. **Captcha Loading**:
   - Verify captcha image loads automatically
   - Image should be visible in the form
   - "새로고침 (Refresh)" button should reload captcha

3. **Enter Credentials**:
   - Enter username in "아이디" field
   - Enter password in "비밀번호" field
   - Enter captcha answer in "보안문자" field

4. **Submit Login**:
   - Click "로그인 (Login)" button
   - Loading indicator should appear
   - On success: Navigate to Home with success message
   - On failure: Error message shown

### Expected Results

#### Success Case

✅ Captcha image loads
✅ Form validation works
✅ Login button becomes disabled during submission
✅ Success snackbar appears
✅ Navigation to Home page
✅ User session is stored locally

#### Error Cases

❌ **Captcha Load Error**:
- Error message displayed
- Retry button available

❌ **Invalid Credentials**:
- Error message: "Login failed: Invalid credentials or captcha"
- Form remains on screen
- User can try again

❌ **Network Error**:
- Error message with network details
- User can refresh captcha and retry

### Manual Test Checklist

- [ ] App launches without errors
- [ ] Can navigate to Settings
- [ ] Can save Base URL
- [ ] Can navigate to Login page
- [ ] Captcha image loads
- [ ] Can refresh captcha
- [ ] Form validation works (empty fields)
- [ ] Password visibility toggle works
- [ ] Login button shows loading state
- [ ] Successful login navigates to Home
- [ ] Error messages display correctly
- [ ] Session persists across app restarts

### Debug Information

#### Check Logs

Look for these log messages:
```
HTTP REQUEST[POST] => PATH: /plugin/kcaptcha/kcaptcha_session.php
HTTP REQUEST[GET] => PATH: /plugin/kcaptcha/kcaptcha_image.php
HTTP REQUEST[POST] => PATH: /bbs/login_check.php
```

#### Check Storage

After successful login, verify:
```dart
// In Hive storage
final user = hiveStorage.get('current_user');
print('Stored user: $user');
```

### Known Limitations

1. **Base URL Required**: Must configure Base URL before login
2. **Captcha Refresh**: Manual refresh only (no auto-refresh)
3. **Session Expiry**: No auto-logout on session expiry (yet)
4. **Network Error**: Generic error messages

### Next Steps After Successful Test

If login works correctly:
1. ✅ Move to Phase 2-2: Home Screen implementation
2. Implement authenticated requests using stored session
3. Add session validation on app start

### Troubleshooting

#### "Base URL not configured" Error
- Go to Settings and set Base URL
- Save settings before attempting login

#### Captcha won't load
- Check Base URL is correct
- Check network connection
- Check console for HTTP errors

#### Login fails with no error
- Check console logs
- Verify API endpoints are correct
- Check if captcha answer is correct

#### App crashes on login
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild and try again

### Files Modified for Testing

```
lib/features/authentication/
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   └── captcha_data.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── prepare_captcha.dart
│       ├── login.dart
│       ├── logout.dart
│       ├── check_login_status.dart
│       └── get_current_user.dart
├── data/
│   ├── models/
│   │   └── user_model.dart
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_local_datasource.dart
│   └── repositories/
│       └── auth_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    ├── pages/
    │   └── login_page.dart
    └── widgets/
        └── login_form.dart

lib/features/settings/presentation/pages/
└── settings_page.dart

lib/features/home/presentation/pages/
└── home_page.dart

lib/config/routes/
└── app_router.dart (updated)
```

## Test Report Template

```markdown
### Test Date: [DATE]
### Tester: [NAME]
### Device: [DEVICE/EMULATOR]
### Flutter Version: [VERSION]

#### Test Results

| Test Case | Status | Notes |
|-----------|--------|-------|
| App Launch | ✅/❌ | |
| Settings Save | ✅/❌ | |
| Captcha Load | ✅/❌ | |
| Captcha Refresh | ✅/❌ | |
| Form Validation | ✅/❌ | |
| Login Success | ✅/❌ | |
| Login Failure | ✅/❌ | |
| Error Messages | ✅/❌ | |
| Session Persistence | ✅/❌ | |

#### Issues Found

1. [Issue description]
2. [Issue description]

#### Screenshots

[Attach screenshots if needed]
```
