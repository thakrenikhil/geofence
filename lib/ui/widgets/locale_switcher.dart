import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/localization/locale_provider.dart';
import '../../flutter_gen/gen_l10n/app_localizations.dart';

class LocaleSwitcher extends StatelessWidget {
  const LocaleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    return DropdownButton<Locale>(
      value: provider.locale,
      onChanged: (locale) => locale != null ? provider.setLocale(locale) : null,
      items: AppLocalizations.supportedLocales
          .map((l) => DropdownMenuItem(value: l, child: Text(l.languageCode.toUpperCase())))
          .toList(),
    );
  }
}


