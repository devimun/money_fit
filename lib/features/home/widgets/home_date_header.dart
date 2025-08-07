import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class HomeDateHeader extends StatelessWidget {
  const HomeDateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        DateFormat(l10n.dateFormat, locale).format(DateTime.now()),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}