# Routes Module

This module provides navigation and routing functionality using GoRouter.

## Components

### RouteNames (`route_names.dart`)
Centralized route name definitions for type-safe navigation.

**Usage:**
```dart
// Navigate using route name
context.goNamed(RouteNames.mangaDetail, pathParameters: {'id': '123'});
context.pushNamed(RouteNames.viewer, pathParameters: {
  'titleId': '123',
  'episodeId': '456',
});
```

### RoutePaths (`route_paths.dart`)
URL path definitions for each route.

**Supported Routes:**
- Root: `/`, `/first-time`
- Auth: `/login`, `/captcha`
- Main: `/home`
- Manga: `/manga/:id`, `/manga/:id/episodes`, `/manga/:id/comments`
- Viewer: `/viewer/:titleId/:episodeId`, `/strip-viewer/:titleId/:episodeId`, `/webtoon-viewer/:titleId/:episodeId`
- Search: `/search`, `/search/advanced`, `/search/tag`
- Download: `/downloads`, `/downloads/queue`
- Favorites: `/favorites`
- Settings: `/settings` (and sub-routes)

### AppRouter (`app_router.dart`)
Main router configuration with GoRouter.

**Features:**
- Automatic redirect on first-time setup
- Type-safe path parameters
- Error handling with custom error page
- Placeholder pages for unimplemented routes

**Usage:**
```dart
// In main.dart
final appRouter = sl<AppRouter>();
return MaterialApp.router(
  routerConfig: appRouter.router,
);

// Navigation
context.go('/home');
context.push('/manga/123');
context.goNamed(RouteNames.mangaDetail, pathParameters: {'id': '123'});

// With query parameters
context.push('/captcha?url=https://example.com/captcha');
```

### RouteGuard (`route_guard.dart`)
Authentication and authorization guards.

**Guards:**
- `authGuard()`: Check if user is authenticated
- `firstTimeGuard()`: Check if first-time setup is complete
- `combinedGuard()`: Combined guard (currently only first-time)

**Usage:**
```dart
// In AppRouter
redirect: (context, state) {
  final guard = RouteGuard(localStorage);
  return guard.combinedGuard(context, state);
}
```

### RouteTransitions (`route_transitions.dart`)
Custom page transitions for routes.

**Available Transitions:**
- `fadeTransition()`: Fade in/out
- `slideTransition()`: Slide from right
- `slideUpTransition()`: Slide from bottom
- `scaleTransition()`: Scale with fade
- `slideFadeTransition()`: Combined slide and fade
- `noTransition()`: Instant (no animation)
- `materialPage()`: Default platform transition

**Usage:**
```dart
GoRoute(
  path: '/example',
  pageBuilder: (context, state) {
    return RouteTransitions.fadeTransition(
      child: ExamplePage(),
      state: state,
      duration: Duration(milliseconds: 300),
    );
  },
)
```

## Navigation Examples

### Basic Navigation

```dart
// Go to route (replace current)
context.go('/home');
context.goNamed(RouteNames.home);

// Push route (add to stack)
context.push('/manga/123');
context.pushNamed(RouteNames.mangaDetail, pathParameters: {'id': '123'});

// Pop route
context.pop();

// Replace route
context.replace('/login');
```

### Path Parameters

```dart
// Manga detail
context.goNamed(
  RouteNames.mangaDetail,
  pathParameters: {'id': '123'},
);

// Viewer
context.goNamed(
  RouteNames.viewer,
  pathParameters: {
    'titleId': '123',
    'episodeId': '456',
  },
);
```

### Query Parameters

```dart
// Captcha with URL
context.push('/captcha?url=https://example.com/captcha');

// Tag search
context.goNamed(
  RouteNames.tagSearch,
  queryParameters: {'tag': 'action'},
);

// In route builder
final captchaUrl = state.uri.queryParameters['url'];
final tag = state.uri.queryParameters['tag'];
```

### Programmatic Navigation

```dart
// In BLoC or ViewModel
final router = sl<AppRouter>();
router.router.go('/home');
router.router.pushNamed(RouteNames.mangaDetail, pathParameters: {'id': '123'});
```

## Route Guard Flow

```
User accesses app
    ↓
First time?
    ↓ Yes
    Redirect to /first-time
    ↓ Complete setup
    ↓
First time = false
    ↓
Authentication required? (Optional)
    ↓ No
    Allow access
    ↓ Yes
    Authenticated?
        ↓ No
        Redirect to /login
        ↓ Login success
        ↓
    Allow access
```

## Legacy App Mapping

| Legacy (Java) | Flutter (Dart) |
|--------------|----------------|
| `Intent` navigation | GoRouter `context.go()` / `context.push()` |
| `startActivity()` | `context.push()` |
| `startActivityForResult()` | `context.push().then()` |
| `finish()` | `context.pop()` |
| Activity stack | Route stack |

## Adding New Routes

1. Add route name to `route_names.dart`:
```dart
static const String newRoute = 'new-route';
```

2. Add route path to `route_paths.dart`:
```dart
static const String newRoute = '/new-route/:id';
```

3. Add route to `app_router.dart`:
```dart
GoRoute(
  path: RoutePaths.newRoute,
  name: RouteNames.newRoute,
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return NewRoutePage(id: id);
  },
),
```

4. Navigate to the route:
```dart
context.goNamed(RouteNames.newRoute, pathParameters: {'id': '123'});
```

## Error Handling

404 and navigation errors are handled by the error builder:
```dart
errorBuilder: (context, state) => _buildErrorPage(state.error),
```

Custom error page shows:
- Error icon
- "Page not found" message
- Error details (if available)
