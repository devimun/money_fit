// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Koniec so zložitými tabuľkami';

  @override
  String get onboardingDescription1 =>
      'Jednoducho spravujte svoje denné výdavky a vytvárajte zdravé finančné návyky.';

  @override
  String get onboardingTitle2 => 'Denný rozpočet na prvý pohľad';

  @override
  String get onboardingDescription2 =>
      'Sledujte zostávajúci rozpočet na dnes a začnite utrácať uvedomele.';

  @override
  String get onboardingTitle3 => 'Premeňte úspechy na trvalé návyky';

  @override
  String get onboardingDescription3 =>
      'Premeňte denné výzvy na úspechy a užívajte si správu peňazí.';

  @override
  String get next => 'Ďalej';

  @override
  String get dailyBudgetSetupTitle => 'Nastavte rozpočet';

  @override
  String get budgetSetupDescription =>
      'Nastavte rozpočet na voľné výdavky. Voľné výdavky sú suma, ktorú môžete voľne použiť, okrem fixných nákladov ako účty, zdravotné výdavky, bývanie a poistenie.';

  @override
  String get dailyBudgetLabel => 'Denný rozpočet';

  @override
  String get monthlyBudgetLabel => 'Mesačný rozpočet';

  @override
  String get enterBudgetPrompt => 'Zadajte prosím rozpočet.';

  @override
  String get enterValidNumberPrompt => 'Zadajte prosím platné číslo.';

  @override
  String get budgetGreaterThanZeroPrompt => 'Rozpočet musí byť väčší ako 0.';

  @override
  String get start => 'Začať';

  @override
  String errorOccurred(Object error) {
    return 'Vyskytla sa chyba: $error';
  }

  @override
  String get dateFormat => 'EEEE d. MMMM yyyy';

  @override
  String get dailyDiscretionarySpending => 'Denné voľné výdavky: ';

  @override
  String get monthlyDiscretionarySpending2 => 'Mesačné voľné výdavky: ';

  @override
  String get dailyBudget => 'Denný voľný rozpočet: ';

  @override
  String get monthlyBudget => 'Mesačný voľný rozpočet: ';

  @override
  String get monthlyAvgDiscSpending => 'Voľné/Deň (Mes.)';

  @override
  String get consecutiveDays => 'Séria úspechov';

  @override
  String days(Object count) {
    return '$count dní';
  }

  @override
  String get viewTodaySpending => 'Zobraziť\ndn. výdavky';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výdavkov',
      few: '$count výdavky',
      one: '1 výdavok',
      zero: 'Zatiaľ žiadne výdavky',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Pridať\ndn. výdavok';

  @override
  String get addNewExpensePrompt => 'Pridajte nový výdavok';

  @override
  String get notificationDialogTitle =>
      'Pomôžeme vám pamätať na zápis výdavkov';

  @override
  String get notificationDialogDescription =>
      'Zapisovať výdavky je jednoduché, ale tiež sa na to ľahko zabudne. Budeme vám posielať denné pripomienky. Chcete dostávať oznámenia?';

  @override
  String get notificationDialogDeny => 'Nie, ďakujem';

  @override
  String get notificationDialogConfirm => 'Áno, prosím';

  @override
  String get category_food => 'Jedlo';

  @override
  String get category_traffic => 'Doprava';

  @override
  String get category_insurance => 'Poistenie';

  @override
  String get category_necessities => 'Nevyhnutnosti';

  @override
  String get category_communication => 'Komunikácia';

  @override
  String get category_housing => 'Bývanie/Služby';

  @override
  String get category_medical => 'Zdravotné';

  @override
  String get category_finance => 'Financie';

  @override
  String get categoryEatingOut => 'Stravovanie vonku';

  @override
  String get category_cafe => 'Kaviareň/Občerstvenie';

  @override
  String get category_shopping => 'Nákupy';

  @override
  String get category_hobby => 'Koníčky/Voľný čas';

  @override
  String get category_travel => 'Cestovanie/Oddych';

  @override
  String get category_subscribe => 'Predplatné';

  @override
  String get category_beauty => 'Krása';

  @override
  String get expenseType_essential => 'Nevyhnutné';

  @override
  String get expenseType_discretionary => 'Voľné';

  @override
  String get dailyExpenseHistory => 'História denných výdavkov';

  @override
  String get noExpenseHistory => 'História výdavkov nenájdená.';

  @override
  String get editDeleteExpense => 'Upraviť/Zmazať výdavok';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Čo chcete urobiť s výdavkom \"$expenseName\"?';
  }

  @override
  String get edit => 'Upraviť';

  @override
  String get delete => 'Zmazať';

  @override
  String get allExpenses => 'Všetky výdavky';

  @override
  String get allCategories => 'Všetky kategórie';

  @override
  String get unknown => 'Neznáme';

  @override
  String get ascending => 'Vzostupne';

  @override
  String get descending => 'Zostupne';

  @override
  String get noExpenseData => 'Žiadne údaje o výdavkoch';

  @override
  String get changeFilterPrompt =>
      'Skúste zmeniť filtre alebo pridajte nový výdavok';

  @override
  String get allFieldsRequired => 'Vyplňte prosím všetky polia správne.';

  @override
  String get addNewCategory => 'Pridať novú kategóriu';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get add => 'Pridať';

  @override
  String get deleteCategory => 'Zmazať kategóriu';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Naozaj chcete zmazať kategóriu \'$categoryName\'?';
  }

  @override
  String get pleaseWait => 'Prosím čakajte...';

  @override
  String get noDataExists => 'Žiadne údaje.';

  @override
  String get reset => 'Resetovať';

  @override
  String get selectDate => 'Vybrať dátum';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Potvrdiť';

  @override
  String get budgetSetting => 'Nastavenie rozpočtu';

  @override
  String get save => 'Uložiť';

  @override
  String get resetInformation => 'Resetovať informácie';

  @override
  String get notificationPermissionRequired => 'Vyžadované povolenie oznámení';

  @override
  String get notificationPermissionDescription =>
      'Pre použitie oznámení ich povoľte v nastaveniach.';

  @override
  String get goToSettings => 'Prejsť do Nastavení';

  @override
  String get monthlyDiscretionarySpending => 'Voľné';

  @override
  String get monthlyEssentialSpending => 'Nevyhnutné';

  @override
  String get success => 'Úspech';

  @override
  String get failure => 'Neúspech';

  @override
  String get consecutiveSuccess => 'Séria';

  @override
  String daysCount(Object count) {
    return '$count dní';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Názov je prázdny.';

  @override
  String get invalidAmount => 'Suma je neplatná alebo menšia alebo rovná 0.';

  @override
  String get categoryNotSelected => 'Kategória nevybraná.';

  @override
  String formValidationError(Object error) {
    return 'Chyba validácie: $error';
  }

  @override
  String get registerExpense => 'Zaregistrovať výdavok';

  @override
  String get register => 'Zaregistrovať';

  @override
  String get date => 'Dátum';

  @override
  String get expenseName => 'Názov výdavku';

  @override
  String get enterExpenseName => 'Zadajte názov výdavku';

  @override
  String get amount => 'Suma';

  @override
  String get enterExpenseAmount => 'Zadajte sumu výdavku';

  @override
  String get expenseType => 'Typ výdavku';

  @override
  String get essentialExpense => 'Nevyhnutný';

  @override
  String get discretionaryExpense => 'Voľný';

  @override
  String get categoryName => 'Názov kategórie';

  @override
  String get sunday => 'Ne';

  @override
  String get monday => 'Po';

  @override
  String get tuesday => 'Ut';

  @override
  String get wednesday => 'St';

  @override
  String get thursday => 'Št';

  @override
  String get friday => 'Pi';

  @override
  String get saturday => 'So';

  @override
  String errorWithMessage(Object error) {
    return 'Chyba: $error';
  }

  @override
  String get darkMode => 'Tmavý režim';

  @override
  String get themeColor => 'Farba témy';

  @override
  String get themeColorDescription => 'Prispôsobte farebnú schému aplikácie';

  @override
  String get fontSize => 'Veľkosť písma';

  @override
  String get fontSizeDescription =>
      'Upravte veľkosť textu pre lepšiu čitateľnosť';

  @override
  String get fontSizeSmall => 'Malé';

  @override
  String get fontSizeMedium => 'Stredné';

  @override
  String get fontSizeLarge => 'Veľké';

  @override
  String get apply => 'Použiť';

  @override
  String get dataManagement => 'Správa údajov';

  @override
  String get resetDataConfirmation =>
      'Naozaj chcete resetovať všetky údaje? Túto akciu nemožno vrátiť.';

  @override
  String get notificationSetting => 'Nastavenie oznámení';

  @override
  String get category => 'Kategória';

  @override
  String get selectExpenseTypeFirst => 'Najprv vyberte typ výdavku';

  @override
  String get errorLoadingCategories => 'Chyba načítania kategórií';

  @override
  String get queryMonth => 'Mesiac dopytu';

  @override
  String get remainingAmount => 'Zostávajúca suma';

  @override
  String get todayExpenseMessageZero => 'Zapíšte si dnešné výdavky 😊';

  @override
  String get todayExpenseMessageGood => 'Skvelé!\nMáte ešte veľa rozpočtu 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Použili ste skoro polovicu!\nBuďme teraz opatrnejší 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Blížite sa k prekročeniu\ndnešného rozpočtu! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Prekročili ste dnešný rozpočet!\nUpravme výdavky ❗';

  @override
  String get information => 'Informácie';

  @override
  String get writeReview => 'Napísať recenziu';

  @override
  String get appVersion => 'Verzia aplikácie';

  @override
  String get privacyPolicy => 'Zásady ochrany osobných údajov';

  @override
  String get basicSettings => 'Základné nastavenia';

  @override
  String get titleAndClose => 'Názov a zavrieť';

  @override
  String get filterSettings => 'Nastavenia filtrov';

  @override
  String get sort => 'Zoradiť';

  @override
  String get latest => 'Najnovšie';

  @override
  String get oldest => 'Najstaršie';

  @override
  String get statistics => 'Štatistiky';

  @override
  String get spendingByCategory => 'Výdavky podľa kategórií';

  @override
  String get top3ExpensesThisMonth => 'Top 3 výdavky tento mesiac';

  @override
  String get home => 'Domov';

  @override
  String get daily => 'Denne';

  @override
  String get monthly => 'Mesačne';

  @override
  String get calendar => 'Kalendár';

  @override
  String get stats => 'Štatistiky';

  @override
  String get expense => 'Výdavky';

  @override
  String get settings => 'Nastavenia';

  @override
  String get notificationTitleDaily => 'Pripomienka výdavkov';

  @override
  String get notificationBodyMorning =>
      'Dobré ráno! ☀️ Pripravení zapísať prvý výdavok dňa? Malé návyky robia veľký rozdiel!';

  @override
  String get notificationBodyAfternoon =>
      'Dobrý obed? 🍱 Čo tak rýchla aktualizácia výdavkov?';

  @override
  String get notificationBodyNight =>
      'Deň takmer končí 🌙 Zakončite ho usporiadaním výdavkov.';

  @override
  String get resetComplete => 'Ďakujeme za používanie MoneyFit.';

  @override
  String get upgraderTitle => 'Dostupná aktualizácia';

  @override
  String get upgraderBody =>
      'Je k dispozícii nová verzia aplikácie. Aktualizujte pre lepší zážitok.';

  @override
  String get upgraderPrompt => 'Chcete aktualizovať teraz?';

  @override
  String get upgraderButtonLater => 'Neskôr';

  @override
  String get upgraderButtonUpdate => 'Aktualizovať teraz';

  @override
  String get upgraderButtonIgnore => 'Ignorovať';

  @override
  String get updateRequiredTitle => 'Vyžadovaná aktualizácia';

  @override
  String get updateRequiredBody =>
      'Aktualizujte na najnovšiu verziu pre najlepší zážitok.';

  @override
  String get updateAvailableBody =>
      'Je k dispozícii nová verzia. Užite si najnovšie funkcie a vylepšenia.';

  @override
  String get updateChangelogTitle => 'Čo je nové';

  @override
  String get updateButton => 'Aktualizovať';

  @override
  String get updateDetails => 'Podrobnosti';

  @override
  String get updateSheetTitle => 'Info o aktualizácii';

  @override
  String get updateButtonGo => 'Prejsť na aktualizáciu';

  @override
  String get review_modal_binary_title => 'Ste spokojní s aplikáciou?';

  @override
  String get review_modal_button_good => 'Páčilo sa mi';

  @override
  String get review_modal_button_bad => 'Veľmi nie';

  @override
  String get review_positive_title => 'Môžete nám povedať, čo sa vám páčilo?';

  @override
  String get review_positive_button_yes => 'Jasné';

  @override
  String get review_button_later => 'Neskôr';

  @override
  String get review_button_never => 'Už nezobrazovať';

  @override
  String get review_negative_title => 'Povedzte nám, čo vám nevyhovovalo.';

  @override
  String get review_negative_hint => 'Povedzte nám, čo bolo nepohodlné.';

  @override
  String get review_negative_button_send => 'Odoslať';

  @override
  String get review_thanks_message =>
      'Ďakujeme za spätnú väzbu. Budeme pracovať na zlepšení.';

  @override
  String get monthlyExpenseMessageZero =>
      'Zatiaľ žiadne voľné výdavky\ntento mesiac!';

  @override
  String get monthlyExpenseMessageGood =>
      'Váš rozpočet je tento mesiac\ndobre spravovaný!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Použili ste približne polovicu rozpočtu\ntento mesiac.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Váš rozpočet je tento mesiac\ntakmer vyčerpaný.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Prekročili ste rozpočet\ntento mesiac.';

  @override
  String get contactUs => 'Kontaktujte nás';

  @override
  String get inquiryType => 'Typ dopytu';

  @override
  String get inquiryTypeBugReport => 'Hlásenie chyby';

  @override
  String get inquiryTypeFeatureSuggestion => 'Návrh funkcie';

  @override
  String get inquiryTypeGeneralInquiry => 'Všeobecný dopyt';

  @override
  String get inquiryTypeOther => 'Iné';

  @override
  String get replyEmail => 'Email pre odpoveď';

  @override
  String get optional => 'Voliteľné';

  @override
  String get inquiryDetails => 'Podrobnosti dopytu';

  @override
  String get submit => 'Odoslať';

  @override
  String get inquirySuccess => 'Váš dopyt bol úspešne odoslaný.';

  @override
  String get inquiryFailure => 'Nepodarilo sa odoslať dopyt.';

  @override
  String get invalidEmail => 'Zadajte platnú emailovú adresu.';

  @override
  String get fieldRequired => 'Toto pole je povinné.';

  @override
  String get selectThemeColor => 'Vybrať farbu témy';

  @override
  String get quickSelect => 'Rýchly výber';

  @override
  String get recentColors => 'Posledné farby';

  @override
  String get customSelect => 'Vlastný výber';

  @override
  String get close => 'Zavrieť';

  @override
  String get languageSetting => 'Jazyk a mena';

  @override
  String get selectLanguage => 'Vybrať jazyk';
}
