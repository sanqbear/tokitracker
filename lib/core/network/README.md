# Network Module

This module provides HTTP client functionality for the application, replacing the legacy `CustomHttpClient.java`.

## Components

### HttpClient (`http_client.dart`)
Main HTTP client wrapper around Dio with the following features:
- Cookie management
- Captcha detection
- Error handling
- Request/response logging
- Support for GET, POST, PUT, DELETE, and file downloads

**Usage:**
```dart
final httpClient = sl<HttpClient>();

// GET request
final response = await httpClient.get('/comic/12345');

// POST request
final response = await httpClient.post(
  '/login',
  data: {'username': 'user', 'password': 'pass'},
);

// Download file
await httpClient.download(
  '/manga/image.jpg',
  '/path/to/save/image.jpg',
  onReceiveProgress: (received, total) {
    print('Progress: ${(received / total * 100).toStringAsFixed(0)}%');
  },
);
```

### Interceptors

#### CaptchaInterceptor (`interceptors/captcha_interceptor.dart`)
Detects when captcha verification is required:
- Monitors 302 redirects to captcha.php
- Checks response body for captcha indicators
- Throws `CaptchaRequiredException` when detected

#### ErrorInterceptor (`interceptors/error_interceptor.dart`)
Converts Dio errors to custom exceptions:
- Network errors → `NetworkException`
- Timeout errors → `TimeoutException`
- Auth errors → `AuthenticationException`
- Server errors → `ServerException`

#### LoggingInterceptor (`interceptors/logging_interceptor.dart`)
Logs all HTTP requests and responses for debugging.

### NetworkInfo (`network_info.dart`)
Provides network connectivity information:
- Check current connection status
- Listen to connectivity changes

**Usage:**
```dart
final networkInfo = sl<NetworkInfo>();

// Check connection
if (await networkInfo.isConnected) {
  // Make network request
}

// Listen to changes
networkInfo.onConnectivityChanged.listen((isConnected) {
  if (isConnected) {
    print('Connected to internet');
  } else {
    print('Disconnected from internet');
  }
});
```

### DioModule (`dio_module.dart`)
Provides dependencies for dependency injection:
- CookieJar (persistent cookie storage)
- Connectivity instance

## Legacy App Mapping

| Legacy (Java) | Flutter (Dart) |
|--------------|----------------|
| `CustomHttpClient.java` | `http_client.dart` |
| `CustomHttpClient.mget()` | `HttpClient.get()` |
| OkHttp | Dio |
| Cookie handling (manual) | CookieJar + CookieManager |
| Captcha detection in response | CaptchaInterceptor |

## Error Handling

All network errors are converted to custom exceptions defined in `core/error/exceptions.dart`:

```dart
try {
  final response = await httpClient.get('/comic/12345');
} on CaptchaRequiredException catch (e) {
  // Handle captcha requirement
  print('Captcha URL: ${e.captchaUrl}');
} on NetworkException catch (e) {
  // Handle network error
  print('Network error: ${e.message}');
} on TimeoutException catch (e) {
  // Handle timeout
  print('Request timeout: ${e.message}');
} on ServerException catch (e) {
  // Handle server error
  print('Server error: ${e.message}');
}
```
