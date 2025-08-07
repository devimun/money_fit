import 'package:flutter/material.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:upgrader/upgrader.dart';

class MyCustomUpgraderMessages extends UpgraderMessages {
  final BuildContext context;
  MyCustomUpgraderMessages({required this.context});
  @override
  String get title => AppLocalizations.of(context)!.upgraderTitle;

  @override
  String get body => AppLocalizations.of(context)!.upgraderBody;

  @override
  String get prompt => AppLocalizations.of(context)!.upgraderPrompt;

  @override
  String get buttonTitleIgnore =>
      AppLocalizations.of(context)!.upgraderButtonIgnore;
  @override
  String get buttonTitleLater =>
      AppLocalizations.of(context)!.upgraderButtonLater;
  @override
  String get buttonTitleUpdate =>
      AppLocalizations.of(context)!.upgraderButtonUpdate;
}
