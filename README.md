# geofence

A new Flutter project.

## Getting Started

Geofence Attendance is a cross-platform Flutter app implementing geofence-based attendance with an admin portal.

Key features

- Multilingual (English, Hindi) using a simple localization service (ARB-ready)
- Responsive UI for mobile, web, and desktop
- Firebase Auth, Firestore, Cloud Functions ready
- Geofencing scaffolding with Google Maps placeholder

Project structure

```
lib/
  models/
    attendance_record.dart
  routing/
    app_router.dart
  services/
    attendance/
      attendance_service.dart
    auth/
      auth_service.dart
    geofence/
      geofence_service_wrapper.dart
    localization/
      app_localizations.dart
      locale_provider.dart
    firebase_initializer.dart
  ui/
    screens/
      splash_screen.dart
      auth/login_screen.dart
      home/employee_home_screen.dart
      home/admin_home_screen.dart
    widgets/
      responsive_scaffold.dart
```

Next steps

- Run `flutterfire configure` and add `firebase_options.dart`, then update `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
- Add Google Maps API keys on each platform.
- Replace placeholders with actual geofencing and dashboards.

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
