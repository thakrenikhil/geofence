import 'package:flutter_test/flutter_test.dart';
import 'package:geofence/flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  test('localization shim returns strings', () {
    final en = AppLocalizations(const Locale('en'));
    final hi = AppLocalizations(const Locale('hi'));
    expect(en.login.isNotEmpty, true);
    expect(hi.login.isNotEmpty, true);
    expect(en.employeeHome, 'Employee Home');
  });
}


