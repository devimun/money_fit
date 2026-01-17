// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Konec se složitými tabulkami';

  @override
  String get onboardingDescription1 =>
      'Snadno spravujte své denní výdaje a vytvářejte zdravé finanční návyky.';

  @override
  String get onboardingTitle2 => 'Denní rozpočet na první pohled';

  @override
  String get onboardingDescription2 =>
      'Sledujte zbývající rozpočet na dnešek a začněte utrácet uvědoměle.';

  @override
  String get onboardingTitle3 => 'Proměňte úspěchy v trvalé návyky';

  @override
  String get onboardingDescription3 =>
      'Proměňte denní výzvy v úspěchy a užívejte si správu peněz.';

  @override
  String get next => 'Další';

  @override
  String get dailyBudgetSetupTitle => 'Nastavte rozpočet';

  @override
  String get budgetSetupDescription =>
      'Nastavte rozpočet na volné výdaje. Volné výdaje jsou částka, kterou můžete volně použít, kromě fixních nákladů jako účty, zdravotní výdaje, bydlení a pojištění.';

  @override
  String get dailyBudgetLabel => 'Denní rozpočet';

  @override
  String get monthlyBudgetLabel => 'Měsíční rozpočet';

  @override
  String get enterBudgetPrompt => 'Zadejte prosím rozpočet.';

  @override
  String get enterValidNumberPrompt => 'Zadejte prosím platné číslo.';

  @override
  String get budgetGreaterThanZeroPrompt => 'Rozpočet musí být větší než 0.';

  @override
  String get start => 'Začít';

  @override
  String errorOccurred(Object error) {
    return 'Došlo k chybě: $error';
  }

  @override
  String get dateFormat => 'd. MMMM yyyy, EEEE';

  @override
  String get dailyDiscretionarySpending => 'Denní volné výdaje: ';

  @override
  String get monthlyDiscretionarySpending2 => 'Měsíční volné výdaje: ';

  @override
  String get dailyBudget => 'Denní volný rozpočet: ';

  @override
  String get monthlyBudget => 'Měsíční volný rozpočet: ';

  @override
  String get monthlyAvgDiscSpending => 'Volné/Den (Měs.)';

  @override
  String get consecutiveDays => 'Série úspěchů';

  @override
  String days(Object count) {
    return '$count dní';
  }

  @override
  String get viewTodaySpending => 'Zobrazit\ndn. výdaje';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výdajů',
      few: '$count výdaje',
      one: '1 výdaj',
      zero: 'Zatím žádné výdaje',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Přidat\ndn. výdaj';

  @override
  String get addNewExpensePrompt => 'Přidejte nový výdaj';

  @override
  String get notificationDialogTitle =>
      'Pomůžeme vám pamatovat na zápis výdajů';

  @override
  String get notificationDialogDescription =>
      'Zapisovat výdaje je snadné, ale také se na to snadno zapomíná. Budeme vám posílat denní připomínky. Chcete dostávat oznámení?';

  @override
  String get notificationDialogDeny => 'Ne, děkuji';

  @override
  String get notificationDialogConfirm => 'Ano, prosím';

  @override
  String get category_food => 'Jídlo';

  @override
  String get category_traffic => 'Doprava';

  @override
  String get category_insurance => 'Pojištění';

  @override
  String get category_necessities => 'Nezbytnosti';

  @override
  String get category_communication => 'Komunikace';

  @override
  String get category_housing => 'Bydlení/Služby';

  @override
  String get category_medical => 'Zdravotní';

  @override
  String get category_finance => 'Finance';

  @override
  String get categoryEatingOut => 'Stravování venku';

  @override
  String get category_cafe => 'Kavárna/Svačiny';

  @override
  String get category_shopping => 'Nákupy';

  @override
  String get category_hobby => 'Koníčky/Volný čas';

  @override
  String get category_travel => 'Cestování/Odpočinek';

  @override
  String get category_subscribe => 'Předplatné';

  @override
  String get category_beauty => 'Krása';

  @override
  String get expenseType_essential => 'Nezbytné';

  @override
  String get expenseType_discretionary => 'Volné';

  @override
  String get dailyExpenseHistory => 'Historie denních výdajů';

  @override
  String get noExpenseHistory => 'Historie výdajů nenalezena.';

  @override
  String get editDeleteExpense => 'Upravit/Smazat výdaj';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Co chcete udělat s výdajem \"$expenseName\"?';
  }

  @override
  String get edit => 'Upravit';

  @override
  String get delete => 'Smazat';

  @override
  String get allExpenses => 'Všechny výdaje';

  @override
  String get allCategories => 'Všechny kategorie';

  @override
  String get unknown => 'Neznámé';

  @override
  String get ascending => 'Vzestupně';

  @override
  String get descending => 'Sestupně';

  @override
  String get noExpenseData => 'Žádná data o výdajích';

  @override
  String get changeFilterPrompt =>
      'Zkuste změnit filtry nebo přidejte nový výdaj';

  @override
  String get allFieldsRequired => 'Vyplňte prosím všechna pole správně.';

  @override
  String get addNewCategory => 'Přidat novou kategorii';

  @override
  String get cancel => 'Zrušit';

  @override
  String get add => 'Přidat';

  @override
  String get deleteCategory => 'Smazat kategorii';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Opravdu chcete smazat kategorii \'$categoryName\'?';
  }

  @override
  String get pleaseWait => 'Prosím čekejte...';

  @override
  String get noDataExists => 'Žádná data.';

  @override
  String get reset => 'Resetovat';

  @override
  String get selectDate => 'Vybrat datum';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Potvrdit';

  @override
  String get budgetSetting => 'Nastavení rozpočtu';

  @override
  String get save => 'Uložit';

  @override
  String get resetInformation => 'Resetovat informace';

  @override
  String get notificationPermissionRequired => 'Vyžadováno povolení oznámení';

  @override
  String get notificationPermissionDescription =>
      'Pro použití oznámení je povolte v nastavení.';

  @override
  String get goToSettings => 'Přejít do Nastavení';

  @override
  String get monthlyDiscretionarySpending => 'Volné';

  @override
  String get monthlyEssentialSpending => 'Nezbytné';

  @override
  String get success => 'Úspěch';

  @override
  String get failure => 'Neúspěch';

  @override
  String get consecutiveSuccess => 'Série';

  @override
  String daysCount(Object count) {
    return '$count dní';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Název je prázdný.';

  @override
  String get invalidAmount => 'Částka je neplatná nebo menší nebo rovna 0.';

  @override
  String get categoryNotSelected => 'Kategorie nevybrána.';

  @override
  String formValidationError(Object error) {
    return 'Chyba validace: $error';
  }

  @override
  String get registerExpense => 'Zaregistrovat výdaj';

  @override
  String get register => 'Zaregistrovat';

  @override
  String get date => 'Datum';

  @override
  String get expenseName => 'Název výdaje';

  @override
  String get enterExpenseName => 'Zadejte název výdaje';

  @override
  String get amount => 'Částka';

  @override
  String get enterExpenseAmount => 'Zadejte částku výdaje';

  @override
  String get expenseType => 'Typ výdaje';

  @override
  String get essentialExpense => 'Nezbytný';

  @override
  String get discretionaryExpense => 'Volný';

  @override
  String get categoryName => 'Název kategorie';

  @override
  String get sunday => 'Ne';

  @override
  String get monday => 'Po';

  @override
  String get tuesday => 'Út';

  @override
  String get wednesday => 'St';

  @override
  String get thursday => 'Čt';

  @override
  String get friday => 'Pá';

  @override
  String get saturday => 'So';

  @override
  String errorWithMessage(Object error) {
    return 'Chyba: $error';
  }

  @override
  String get darkMode => 'Tmavý režim';

  @override
  String get themeColor => 'Barva motivu';

  @override
  String get themeColorDescription => 'Přizpůsobte barevné schéma aplikace';

  @override
  String get fontSize => 'Velikost písma';

  @override
  String get fontSizeDescription =>
      'Upravte velikost textu pro lepší čitelnost';

  @override
  String get fontSizeSmall => 'Malé';

  @override
  String get fontSizeMedium => 'Střední';

  @override
  String get fontSizeLarge => 'Velké';

  @override
  String get apply => 'Použít';

  @override
  String get dataManagement => 'Správa dat';

  @override
  String get resetDataConfirmation =>
      'Opravdu chcete resetovat všechna data? Tuto akci nelze vrátit.';

  @override
  String get notificationSetting => 'Nastavení oznámení';

  @override
  String get category => 'Kategorie';

  @override
  String get selectExpenseTypeFirst => 'Nejprve vyberte typ výdaje';

  @override
  String get errorLoadingCategories => 'Chyba načítání kategorií';

  @override
  String get queryMonth => 'Měsíc dotazu';

  @override
  String get remainingAmount => 'Zbývající částka';

  @override
  String get todayExpenseMessageZero => 'Zapište své dnešní výdaje 😊';

  @override
  String get todayExpenseMessageGood => 'Skvělé!\nMáte ještě hodně rozpočtu 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Použili jste skoro polovinu!\nBuďme teď opatrnější 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Blížíte se k překročení\ndnešního rozpočtu! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Překročili jste dnešní rozpočet!\nUpravme výdaje ❗';

  @override
  String get information => 'Informace';

  @override
  String get writeReview => 'Napsat recenzi';

  @override
  String get appVersion => 'Verze aplikace';

  @override
  String get privacyPolicy => 'Zásady ochrany osobních údajů';

  @override
  String get basicSettings => 'Základní nastavení';

  @override
  String get titleAndClose => 'Název a zavřít';

  @override
  String get filterSettings => 'Nastavení filtrů';

  @override
  String get sort => 'Řadit';

  @override
  String get latest => 'Nejnovější';

  @override
  String get oldest => 'Nejstarší';

  @override
  String get statistics => 'Statistiky';

  @override
  String get spendingByCategory => 'Výdaje podle kategorií';

  @override
  String get top3ExpensesThisMonth => 'Top 3 výdaje tento měsíc';

  @override
  String get home => 'Domů';

  @override
  String get daily => 'Denně';

  @override
  String get monthly => 'Měsíčně';

  @override
  String get calendar => 'Kalendář';

  @override
  String get stats => 'Statistiky';

  @override
  String get expense => 'Výdaje';

  @override
  String get settings => 'Nastavení';

  @override
  String get notificationTitleDaily => 'Připomínka výdajů';

  @override
  String get notificationBodyMorning =>
      'Dobré ráno! ☀️ Připraveni zapsat první výdaj dne? Malé návyky dělají velký rozdíl!';

  @override
  String get notificationBodyAfternoon =>
      'Dobrý oběd? 🍱 Co takhle rychlá aktualizace výdajů?';

  @override
  String get notificationBodyNight =>
      'Den téměř končí 🌙 Zakončete ho uspořádáním výdajů.';

  @override
  String get resetComplete => 'Děkujeme za používání MoneyFit.';

  @override
  String get upgraderTitle => 'Dostupná aktualizace';

  @override
  String get upgraderBody =>
      'Je k dispozici nová verze aplikace. Aktualizujte pro lepší zážitek.';

  @override
  String get upgraderPrompt => 'Chcete aktualizovat nyní?';

  @override
  String get upgraderButtonLater => 'Později';

  @override
  String get upgraderButtonUpdate => 'Aktualizovat nyní';

  @override
  String get upgraderButtonIgnore => 'Ignorovat';

  @override
  String get updateRequiredTitle => 'Vyžadována aktualizace';

  @override
  String get updateRequiredBody =>
      'Aktualizujte na nejnovější verzi pro nejlepší zážitek.';

  @override
  String get updateAvailableBody =>
      'Je k dispozici nová verze. Užijte si nejnovější funkce a vylepšení.';

  @override
  String get updateChangelogTitle => 'Co je nového';

  @override
  String get updateButton => 'Aktualizovat';

  @override
  String get updateDetails => 'Podrobnosti';

  @override
  String get updateSheetTitle => 'Info o aktualizaci';

  @override
  String get updateButtonGo => 'Přejít na aktualizaci';

  @override
  String get review_modal_binary_title => 'Jste spokojeni s aplikací?';

  @override
  String get review_modal_button_good => 'Líbilo se mi';

  @override
  String get review_modal_button_bad => 'Moc ne';

  @override
  String get review_positive_title => 'Můžete nám říct, co se vám líbilo?';

  @override
  String get review_positive_button_yes => 'Jasně';

  @override
  String get review_button_later => 'Později';

  @override
  String get review_button_never => 'Už nezobrazovat';

  @override
  String get review_negative_title => 'Řekněte nám, co vám nevyhovovalo.';

  @override
  String get review_negative_hint => 'Řekněte nám, co bylo nepohodlné.';

  @override
  String get review_negative_button_send => 'Odeslat';

  @override
  String get review_thanks_message =>
      'Děkujeme za zpětnou vazbu. Budeme pracovat na zlepšení.';

  @override
  String get monthlyExpenseMessageZero =>
      'Zatím žádné volné výdaje\ntento měsíc!';

  @override
  String get monthlyExpenseMessageGood =>
      'Váš rozpočet je tento měsíc\ndobře spravován!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Použili jste přibližně polovinu\nrozpočtu tento měsíc.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Váš rozpočet je tento měsíc\ntéměř vyčerpán.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Překročili jste rozpočet\ntento měsíc.';

  @override
  String get contactUs => 'Kontaktujte nás';

  @override
  String get inquiryType => 'Typ dotazu';

  @override
  String get inquiryTypeBugReport => 'Hlášení chyby';

  @override
  String get inquiryTypeFeatureSuggestion => 'Návrh funkce';

  @override
  String get inquiryTypeGeneralInquiry => 'Obecný dotaz';

  @override
  String get inquiryTypeOther => 'Jiné';

  @override
  String get replyEmail => 'Email pro odpověď';

  @override
  String get optional => 'Volitelné';

  @override
  String get inquiryDetails => 'Podrobnosti dotazu';

  @override
  String get submit => 'Odeslat';

  @override
  String get inquirySuccess => 'Váš dotaz byl úspěšně odeslán.';

  @override
  String get inquiryFailure => 'Nepodařilo se odeslat dotaz.';

  @override
  String get invalidEmail => 'Zadejte platnou emailovou adresu.';

  @override
  String get fieldRequired => 'Toto pole je povinné.';

  @override
  String get selectThemeColor => 'Vybrat barvu motivu';

  @override
  String get quickSelect => 'Rychlý výběr';

  @override
  String get recentColors => 'Poslední barvy';

  @override
  String get customSelect => 'Vlastní výběr';

  @override
  String get close => 'Zavřít';

  @override
  String get languageSetting => 'Jazyk a měna';

  @override
  String get selectLanguage => 'Vybrat jazyk';
}
