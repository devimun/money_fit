// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Schluss mit komplizierten Tabellen';

  @override
  String get onboardingDescription1 =>
      'Verwalten Sie Ihre täglichen Ausgaben einfach und entwickeln Sie gesunde Ausgabegewohnheiten.';

  @override
  String get onboardingTitle2 => 'Tagesbudget auf einen Blick';

  @override
  String get onboardingDescription2 =>
      'Verfolgen Sie Ihr verbleibendes Budget für heute und beginnen Sie bewusst auszugeben.';

  @override
  String get onboardingTitle3 =>
      'Verwandeln Sie Erfolge in dauerhafte Gewohnheiten';

  @override
  String get onboardingDescription3 =>
      'Verwandeln Sie tägliche Herausforderungen in Erfolge und genießen Sie die Geldverwaltung.';

  @override
  String get next => 'Weiter';

  @override
  String get dailyBudgetSetupTitle => 'Budget festlegen';

  @override
  String get budgetSetupDescription =>
      'Legen Sie Ihr Budget für freie Ausgaben fest. Freie Ausgaben sind der Betrag, den Sie frei verwenden können, ohne Fixkosten wie Rechnungen, Arztkosten, Wohnung und Versicherung.';

  @override
  String get dailyBudgetLabel => 'Tagesbudget';

  @override
  String get monthlyBudgetLabel => 'Monatsbudget';

  @override
  String get enterBudgetPrompt => 'Bitte geben Sie Ihr Budget ein.';

  @override
  String get enterValidNumberPrompt => 'Bitte geben Sie eine gültige Zahl ein.';

  @override
  String get budgetGreaterThanZeroPrompt =>
      'Das Budget muss größer als 0 sein.';

  @override
  String get start => 'Starten';

  @override
  String errorOccurred(Object error) {
    return 'Ein Fehler ist aufgetreten: $error';
  }

  @override
  String get dateFormat => 'EEEE, d. MMMM yyyy';

  @override
  String get dailyDiscretionarySpending => 'Tägliche freie Ausgaben: ';

  @override
  String get monthlyDiscretionarySpending2 => 'Monatliche freie Ausgaben: ';

  @override
  String get dailyBudget => 'Tägliches freies Budget: ';

  @override
  String get monthlyBudget => 'Monatliches freies Budget: ';

  @override
  String get monthlyAvgDiscSpending => 'Frei/Tag (Mon.)';

  @override
  String get consecutiveDays => 'Erfolgsserie';

  @override
  String days(Object count) {
    return '$count Tage';
  }

  @override
  String get viewTodaySpending => 'Heutige\nAusgaben';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ausgaben',
      one: '1 Ausgabe',
      zero: 'Noch keine Ausgaben',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Heutige\nAusgabe hinzufügen';

  @override
  String get addNewExpensePrompt => 'Neue Ausgabe hinzufügen';

  @override
  String get notificationDialogTitle =>
      'Wir helfen Ihnen, Ausgaben zu notieren';

  @override
  String get notificationDialogDescription =>
      'Ausgaben zu notieren ist einfach, aber man vergisst es leicht. Wir senden Ihnen tägliche Erinnerungen. Möchten Sie Benachrichtigungen erhalten?';

  @override
  String get notificationDialogDeny => 'Nein, danke';

  @override
  String get notificationDialogConfirm => 'Ja, bitte';

  @override
  String get category_food => 'Essen';

  @override
  String get category_traffic => 'Verkehr';

  @override
  String get category_insurance => 'Versicherung';

  @override
  String get category_necessities => 'Notwendigkeiten';

  @override
  String get category_communication => 'Kommunikation';

  @override
  String get category_housing => 'Wohnen/Nebenkosten';

  @override
  String get category_medical => 'Medizinisch';

  @override
  String get category_finance => 'Finanzen';

  @override
  String get categoryEatingOut => 'Auswärts essen';

  @override
  String get category_cafe => 'Café/Snacks';

  @override
  String get category_shopping => 'Einkaufen';

  @override
  String get category_hobby => 'Hobby/Freizeit';

  @override
  String get category_travel => 'Reisen/Erholung';

  @override
  String get category_subscribe => 'Abonnements';

  @override
  String get category_beauty => 'Schönheit';

  @override
  String get expenseType_essential => 'Notwendig';

  @override
  String get expenseType_discretionary => 'Frei';

  @override
  String get dailyExpenseHistory => 'Tägliche Ausgabenhistorie';

  @override
  String get noExpenseHistory => 'Keine Ausgabenhistorie gefunden.';

  @override
  String get editDeleteExpense => 'Ausgabe bearbeiten/löschen';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Was möchten Sie mit der Ausgabe \"$expenseName\" tun?';
  }

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get allExpenses => 'Alle Ausgaben';

  @override
  String get allCategories => 'Alle Kategorien';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get ascending => 'Aufsteigend';

  @override
  String get descending => 'Absteigend';

  @override
  String get noExpenseData => 'Keine Ausgabendaten';

  @override
  String get changeFilterPrompt =>
      'Versuchen Sie, die Filter zu ändern oder fügen Sie eine neue Ausgabe hinzu';

  @override
  String get allFieldsRequired => 'Bitte füllen Sie alle Felder korrekt aus.';

  @override
  String get addNewCategory => 'Neue Kategorie hinzufügen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get deleteCategory => 'Kategorie löschen';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Möchten Sie die Kategorie \'$categoryName\' wirklich löschen?';
  }

  @override
  String get pleaseWait => 'Bitte warten...';

  @override
  String get noDataExists => 'Keine Daten vorhanden.';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Bestätigen';

  @override
  String get budgetSetting => 'Budgeteinstellung';

  @override
  String get save => 'Speichern';

  @override
  String get resetInformation => 'Informationen zurücksetzen';

  @override
  String get notificationPermissionRequired =>
      'Benachrichtigungsberechtigung erforderlich';

  @override
  String get notificationPermissionDescription =>
      'Um Benachrichtigungen zu nutzen, erlauben Sie diese in den Einstellungen.';

  @override
  String get goToSettings => 'Zu Einstellungen';

  @override
  String get monthlyDiscretionarySpending => 'Frei';

  @override
  String get monthlyEssentialSpending => 'Notwendig';

  @override
  String get success => 'Erfolg';

  @override
  String get failure => 'Misserfolg';

  @override
  String get consecutiveSuccess => 'Serie';

  @override
  String daysCount(Object count) {
    return '$count Tage';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Name ist leer.';

  @override
  String get invalidAmount => 'Betrag ist ungültig oder kleiner oder gleich 0.';

  @override
  String get categoryNotSelected => 'Kategorie nicht ausgewählt.';

  @override
  String formValidationError(Object error) {
    return 'Validierungsfehler: $error';
  }

  @override
  String get registerExpense => 'Ausgabe registrieren';

  @override
  String get register => 'Registrieren';

  @override
  String get date => 'Datum';

  @override
  String get expenseName => 'Ausgabenname';

  @override
  String get enterExpenseName => 'Geben Sie den Ausgabennamen ein';

  @override
  String get amount => 'Betrag';

  @override
  String get enterExpenseAmount => 'Geben Sie den Ausgabenbetrag ein';

  @override
  String get expenseType => 'Ausgabentyp';

  @override
  String get essentialExpense => 'Notwendig';

  @override
  String get discretionaryExpense => 'Frei';

  @override
  String get categoryName => 'Kategoriename';

  @override
  String get sunday => 'So';

  @override
  String get monday => 'Mo';

  @override
  String get tuesday => 'Di';

  @override
  String get wednesday => 'Mi';

  @override
  String get thursday => 'Do';

  @override
  String get friday => 'Fr';

  @override
  String get saturday => 'Sa';

  @override
  String errorWithMessage(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get themeColor => 'Themenfarbe';

  @override
  String get themeColorDescription => 'Passen Sie das Farbschema der App an';

  @override
  String get fontSize => 'Schriftgröße';

  @override
  String get fontSizeDescription =>
      'Passen Sie die Textgröße für bessere Lesbarkeit an';

  @override
  String get fontSizeSmall => 'Klein';

  @override
  String get fontSizeMedium => 'Mittel';

  @override
  String get fontSizeLarge => 'Groß';

  @override
  String get apply => 'Anwenden';

  @override
  String get dataManagement => 'Datenverwaltung';

  @override
  String get resetDataConfirmation =>
      'Möchten Sie wirklich alle Daten zurücksetzen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get notificationSetting => 'Benachrichtigungseinstellung';

  @override
  String get category => 'Kategorie';

  @override
  String get selectExpenseTypeFirst => 'Wählen Sie zuerst den Ausgabentyp';

  @override
  String get errorLoadingCategories => 'Fehler beim Laden der Kategorien';

  @override
  String get queryMonth => 'Abfragemonat';

  @override
  String get remainingAmount => 'Verbleibender Betrag';

  @override
  String get todayExpenseMessageZero =>
      'Notieren Sie\nIhre heutigen Ausgaben 😊';

  @override
  String get todayExpenseMessageGood =>
      'Super!\nSie haben noch viel Budget übrig 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Sie haben fast die Hälfte verbraucht!\nSeien wir jetzt vorsichtiger 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Sie sind kurz davor,\ndas heutige Budget zu überschreiten! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Sie haben das heutige Budget überschritten!\nPassen wir die Ausgaben an ❗';

  @override
  String get information => 'Information';

  @override
  String get writeReview => 'Bewertung schreiben';

  @override
  String get appVersion => 'App-Version';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get basicSettings => 'Grundeinstellungen';

  @override
  String get titleAndClose => 'Titel & Schließen';

  @override
  String get filterSettings => 'Filtereinstellungen';

  @override
  String get sort => 'Sortieren';

  @override
  String get latest => 'Neueste';

  @override
  String get oldest => 'Älteste';

  @override
  String get statistics => 'Statistiken';

  @override
  String get spendingByCategory => 'Ausgaben nach Kategorie';

  @override
  String get top3ExpensesThisMonth => 'Top 3 Ausgaben diesen Monat';

  @override
  String get home => 'Startseite';

  @override
  String get daily => 'Täglich';

  @override
  String get monthly => 'Monatlich';

  @override
  String get calendar => 'Kalender';

  @override
  String get stats => 'Statistiken';

  @override
  String get expense => 'Ausgaben';

  @override
  String get settings => 'Einstellungen';

  @override
  String get notificationTitleDaily => 'Tägliche Ausgabenerinnerung';

  @override
  String get notificationBodyMorning =>
      'Guten Morgen! ☀️ Bereit, die erste Ausgabe des Tages zu notieren? Kleine Gewohnheiten machen einen großen Unterschied!';

  @override
  String get notificationBodyAfternoon =>
      'Gutes Mittagessen gehabt? 🍱 Wie wäre es mit einer schnellen Aktualisierung der Ausgaben?';

  @override
  String get notificationBodyNight =>
      'Der Tag ist fast vorbei 🌙 Beenden Sie ihn mit der Organisation Ihrer Ausgaben.';

  @override
  String get resetComplete => 'Danke, dass Sie MoneyFit nutzen.';

  @override
  String get upgraderTitle => 'Update verfügbar';

  @override
  String get upgraderBody =>
      'Eine neue Version der App ist verfügbar. Bitte aktualisieren Sie für ein besseres Erlebnis.';

  @override
  String get upgraderPrompt => 'Möchten Sie jetzt aktualisieren?';

  @override
  String get upgraderButtonLater => 'Später';

  @override
  String get upgraderButtonUpdate => 'Jetzt aktualisieren';

  @override
  String get upgraderButtonIgnore => 'Ignorieren';

  @override
  String get updateRequiredTitle => 'Update erforderlich';

  @override
  String get updateRequiredBody =>
      'Bitte aktualisieren Sie auf die neueste Version für das beste Erlebnis.';

  @override
  String get updateAvailableBody =>
      'Eine neue Version ist verfügbar. Genießen Sie die neuesten Funktionen und Verbesserungen.';

  @override
  String get updateChangelogTitle => 'Was ist neu';

  @override
  String get updateButton => 'Aktualisieren';

  @override
  String get updateDetails => 'Details';

  @override
  String get updateSheetTitle => 'Update-Info';

  @override
  String get updateButtonGo => 'Zum Update';

  @override
  String get review_modal_binary_title => 'Sind Sie mit der App zufrieden?';

  @override
  String get review_modal_button_good => 'Hat mir gefallen';

  @override
  String get review_modal_button_bad => 'Nicht wirklich';

  @override
  String get review_positive_title =>
      'Können Sie uns sagen, was Ihnen gefallen hat?';

  @override
  String get review_positive_button_yes => 'Klar';

  @override
  String get review_button_later => 'Später';

  @override
  String get review_button_never => 'Nicht mehr anzeigen';

  @override
  String get review_negative_title =>
      'Sagen Sie uns, was nicht funktioniert hat.';

  @override
  String get review_negative_hint => 'Sagen Sie uns, was unbequem war.';

  @override
  String get review_negative_button_send => 'Senden';

  @override
  String get review_thanks_message =>
      'Danke für Ihr Feedback. Wir werden daran arbeiten, es zu verbessern.';

  @override
  String get monthlyExpenseMessageZero =>
      'Noch keine freien Ausgaben\ndiesen Monat!';

  @override
  String get monthlyExpenseMessageGood =>
      'Ihr Budget ist diesen Monat\ngut verwaltet!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Sie haben etwa die Hälfte\nIhres Budgets diesen Monat verbraucht.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Ihr Budget ist diesen Monat\nfast aufgebraucht.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Sie haben Ihr Budget\ndiesen Monat überschritten.';

  @override
  String get contactUs => 'Kontaktieren Sie uns';

  @override
  String get inquiryType => 'Anfragetyp';

  @override
  String get inquiryTypeBugReport => 'Fehlerbericht';

  @override
  String get inquiryTypeFeatureSuggestion => 'Funktionsvorschlag';

  @override
  String get inquiryTypeGeneralInquiry => 'Allgemeine Anfrage';

  @override
  String get inquiryTypeOther => 'Sonstiges';

  @override
  String get replyEmail => 'E-Mail für Antwort';

  @override
  String get optional => 'Optional';

  @override
  String get inquiryDetails => 'Anfragedetails';

  @override
  String get submit => 'Absenden';

  @override
  String get inquirySuccess => 'Ihre Anfrage wurde erfolgreich gesendet.';

  @override
  String get inquiryFailure => 'Anfrage konnte nicht gesendet werden.';

  @override
  String get invalidEmail => 'Bitte geben Sie eine gültige E-Mail-Adresse ein.';

  @override
  String get fieldRequired => 'Dieses Feld ist erforderlich.';

  @override
  String get selectThemeColor => 'Themenfarbe auswählen';

  @override
  String get quickSelect => 'Schnellauswahl';

  @override
  String get recentColors => 'Letzte Farben';

  @override
  String get customSelect => 'Eigene Auswahl';

  @override
  String get close => 'Schließen';

  @override
  String get languageSetting => 'Sprache & Währung';

  @override
  String get selectLanguage => 'Sprache auswählen';
}
