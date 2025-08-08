import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = <String, Map<String, String>>{
    'en': {
      'app_title': 'Geofence Attendance',
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'sign_in': 'Sign in',
      'sign_out': 'Sign out',
      'employee_home': 'Employee Home',
      'admin_home': 'Admin Dashboard',
      'check_in': 'Check In',
      'check_out': 'Check Out',
      'offline_mode': 'Offline mode',
    },
    'hi': {
      'app_title': 'जियोफेंस उपस्थिति',
      'login': 'लॉगिन',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'sign_in': 'साइन इन',
      'sign_out': 'साइन आउट',
      'employee_home': 'कर्मचारी होम',
      'admin_home': 'एडमिन डैशबोर्ड',
      'check_in': 'चेक इन',
      'check_out': 'चेक आउट',
      'offline_mode': 'ऑफ़लाइन मोड',
    },
  };

  String t(String key) => _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key] ?? key;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    Intl.defaultLocale = locale.toLanguageTag();
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}


