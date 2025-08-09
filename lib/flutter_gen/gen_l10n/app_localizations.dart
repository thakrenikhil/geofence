import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

// Shim for generated AppLocalizations to keep analysis/tests green in this environment.
class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations);

  String get appTitle => _values('appTitle');
  String get login => _values('login');
  String get email => _values('email');
  String get password => _values('password');
  String get signIn => _values('signIn');
  String get signOut => _values('signOut');
  String get signUp => _values('signUp');
  String get name => _values('name');
  String get confirmPassword => _values('confirmPassword');
  String get employeeHome => _values('employeeHome');
  String get adminHome => _values('adminHome');
  String get checkIn => _values('checkIn');
  String get checkOut => _values('checkOut');
  String get offlineMode => _values('offlineMode');

  String _values(String key) {
    final map = _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return map[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

const Map<String, Map<String, String>> _localizedValues = <String, Map<String, String>>{
  'en': {
    'appTitle': 'Geofence Attendance',
    'login': 'Login',
    'email': 'Email',
    'password': 'Password',
    'signIn': 'Sign in',
    'signOut': 'Sign out',
    'employeeHome': 'Employee Home',
    'adminHome': 'Admin Dashboard',
    'checkIn': 'Check In',
    'checkOut': 'Check Out',
    'offlineMode': 'Offline mode'
  },
  'hi': {
    'appTitle': 'जियोफेंस उपस्थिति',
    'login': 'लॉगिन',
    'email': 'ईमेल',
    'password': 'पासवर्ड',
    'signIn': 'साइन इन',
    'signOut': 'साइन आउट',
    'employeeHome': 'कर्मचारी होम',
    'adminHome': 'एडमिन डैशबोर्ड',
    'checkIn': 'चेक इन',
    'checkOut': 'चेक आउट',
    'offlineMode': 'ऑफ़लाइन मोड'
  }
};


