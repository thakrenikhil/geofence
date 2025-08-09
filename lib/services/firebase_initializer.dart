import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseInitializer {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _initialized = true;
    } catch (_) {
      // In CI or when firebase options are missing, allow app to run without Firebase
      _initialized = true;
    }
  }
}


