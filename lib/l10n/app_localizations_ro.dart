// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Gata cu foile de calcul complicate';

  @override
  String get onboardingDescription1 =>
      'Gestionează-ți ușor cheltuielile zilnice și creează obiceiuri sănătoase de cheltuieli.';

  @override
  String get onboardingTitle2 => 'Bugetul zilnic dintr-o privire';

  @override
  String get onboardingDescription2 =>
      'Urmărește bugetul rămas pentru azi și începe să cheltuiești conștient.';

  @override
  String get onboardingTitle3 => 'Transformă realizările în obiceiuri durabile';

  @override
  String get onboardingDescription3 =>
      'Transformă provocările zilnice în realizări și bucură-te de gestionarea banilor.';

  @override
  String get next => 'Următorul';

  @override
  String get dailyBudgetSetupTitle => 'Setează bugetul';

  @override
  String get budgetSetupDescription =>
      'Setează bugetul pentru cheltuieli discreționare. Cheltuielile discreționare sunt suma pe care o poți folosi liber, excluzând costurile fixe precum facturile, cheltuielile medicale, locuința și asigurările.';

  @override
  String get dailyBudgetLabel => 'Buget zilnic';

  @override
  String get monthlyBudgetLabel => 'Buget lunar';

  @override
  String get enterBudgetPrompt => 'Te rugăm să introduci bugetul.';

  @override
  String get enterValidNumberPrompt => 'Te rugăm să introduci un număr valid.';

  @override
  String get budgetGreaterThanZeroPrompt =>
      'Bugetul trebuie să fie mai mare de 0.';

  @override
  String get start => 'Începe';

  @override
  String errorOccurred(Object error) {
    return 'A apărut o eroare: $error';
  }

  @override
  String get dateFormat => 'EEEE, d MMMM yyyy';

  @override
  String get dailyDiscretionarySpending => 'Cheltuieli discreționare zilnice: ';

  @override
  String get monthlyDiscretionarySpending2 =>
      'Cheltuieli discreționare lunare: ';

  @override
  String get dailyBudget => 'Buget discreționare zilnic: ';

  @override
  String get monthlyBudget => 'Buget discreționare lunar: ';

  @override
  String get monthlyAvgDiscSpending => 'Discr/Zi (Lună)';

  @override
  String get consecutiveDays => 'Serie de succese';

  @override
  String days(Object count) {
    return '$count zile';
  }

  @override
  String get viewTodaySpending => 'Vezi cheltuielile\nde azi';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cheltuieli',
      few: '$count cheltuieli',
      one: '1 cheltuială',
      zero: 'Nicio cheltuială încă',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Adaugă\ncheltuială de azi';

  @override
  String get addNewExpensePrompt => 'Adaugă o cheltuială nouă';

  @override
  String get notificationDialogTitle =>
      'Te vom ajuta să îți amintești să înregistrezi cheltuielile';

  @override
  String get notificationDialogDescription =>
      'Înregistrarea cheltuielilor este ușoară, dar este și ușor de uitat. Îți vom trimite memento-uri zilnice. Vrei să primești notificări?';

  @override
  String get notificationDialogDeny => 'Nu, mulțumesc';

  @override
  String get notificationDialogConfirm => 'Da, te rog';

  @override
  String get category_food => 'Mâncare';

  @override
  String get category_traffic => 'Transport';

  @override
  String get category_insurance => 'Asigurări';

  @override
  String get category_necessities => 'Necesități';

  @override
  String get category_communication => 'Comunicații';

  @override
  String get category_housing => 'Locuință/Utilități';

  @override
  String get category_medical => 'Medical';

  @override
  String get category_finance => 'Finanțe';

  @override
  String get categoryEatingOut => 'Mâncat în oraș';

  @override
  String get category_cafe => 'Cafenea/Gustări';

  @override
  String get category_shopping => 'Cumpărături';

  @override
  String get category_hobby => 'Hobby/Timp liber';

  @override
  String get category_travel => 'Călătorii/Relaxare';

  @override
  String get category_subscribe => 'Abonamente';

  @override
  String get category_beauty => 'Frumusețe';

  @override
  String get expenseType_essential => 'Esențial';

  @override
  String get expenseType_discretionary => 'Discreționare';

  @override
  String get dailyExpenseHistory => 'Istoric cheltuieli zilnice';

  @override
  String get noExpenseHistory => 'Nu s-a găsit istoric de cheltuieli.';

  @override
  String get editDeleteExpense => 'Editează/Șterge cheltuială';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Ce vrei să faci cu cheltuiala \"$expenseName\"?';
  }

  @override
  String get edit => 'Editează';

  @override
  String get delete => 'Șterge';

  @override
  String get allExpenses => 'Toate cheltuielile';

  @override
  String get allCategories => 'Toate categoriile';

  @override
  String get unknown => 'Necunoscut';

  @override
  String get ascending => 'Crescător';

  @override
  String get descending => 'Descrescător';

  @override
  String get noExpenseData => 'Nu există date despre cheltuieli';

  @override
  String get changeFilterPrompt =>
      'Încearcă să schimbi filtrele sau adaugă o cheltuială nouă';

  @override
  String get allFieldsRequired =>
      'Te rugăm să completezi toate câmpurile corect.';

  @override
  String get addNewCategory => 'Adaugă categorie nouă';

  @override
  String get cancel => 'Anulează';

  @override
  String get add => 'Adaugă';

  @override
  String get deleteCategory => 'Șterge categoria';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Ești sigur că vrei să ștergi categoria \'$categoryName\'?';
  }

  @override
  String get pleaseWait => 'Te rugăm să aștepți...';

  @override
  String get noDataExists => 'Nu există date.';

  @override
  String get reset => 'Resetează';

  @override
  String get selectDate => 'Selectează data';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Confirmă';

  @override
  String get budgetSetting => 'Setare buget';

  @override
  String get save => 'Salvează';

  @override
  String get resetInformation => 'Resetează informațiile';

  @override
  String get notificationPermissionRequired => 'Permisiune notificări necesară';

  @override
  String get notificationPermissionDescription =>
      'Pentru a folosi notificările, permite-le în setări.';

  @override
  String get goToSettings => 'Mergi la Setări';

  @override
  String get monthlyDiscretionarySpending => 'Discreționare';

  @override
  String get monthlyEssentialSpending => 'Esențial';

  @override
  String get success => 'Succes';

  @override
  String get failure => 'Eșec';

  @override
  String get consecutiveSuccess => 'Serie';

  @override
  String daysCount(Object count) {
    return '$count zile';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Numele este gol.';

  @override
  String get invalidAmount =>
      'Suma nu este validă sau este mai mică sau egală cu 0.';

  @override
  String get categoryNotSelected => 'Categoria nu este selectată.';

  @override
  String formValidationError(Object error) {
    return 'Eroare de validare: $error';
  }

  @override
  String get registerExpense => 'Înregistrează cheltuială';

  @override
  String get register => 'Înregistrează';

  @override
  String get date => 'Data';

  @override
  String get expenseName => 'Nume cheltuială';

  @override
  String get enterExpenseName => 'Introdu numele cheltuielii';

  @override
  String get amount => 'Sumă';

  @override
  String get enterExpenseAmount => 'Introdu suma cheltuielii';

  @override
  String get expenseType => 'Tip cheltuială';

  @override
  String get essentialExpense => 'Esențială';

  @override
  String get discretionaryExpense => 'Discreționară';

  @override
  String get categoryName => 'Nume categorie';

  @override
  String get sunday => 'Dum';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Mie';

  @override
  String get thursday => 'Joi';

  @override
  String get friday => 'Vin';

  @override
  String get saturday => 'Sâm';

  @override
  String errorWithMessage(Object error) {
    return 'Eroare: $error';
  }

  @override
  String get darkMode => 'Mod întunecat';

  @override
  String get themeColor => 'Culoare temă';

  @override
  String get themeColorDescription =>
      'Personalizează schema de culori a aplicației';

  @override
  String get fontSize => 'Dimensiune font';

  @override
  String get fontSizeDescription =>
      'Ajustează dimensiunea textului pentru o citire mai bună';

  @override
  String get fontSizeSmall => 'Mic';

  @override
  String get fontSizeMedium => 'Mediu';

  @override
  String get fontSizeLarge => 'Mare';

  @override
  String get apply => 'Aplică';

  @override
  String get dataManagement => 'Gestionare date';

  @override
  String get resetDataConfirmation =>
      'Ești sigur că vrei să resetezi toate datele? Această acțiune nu poate fi anulată.';

  @override
  String get notificationSetting => 'Setare notificări';

  @override
  String get category => 'Categorie';

  @override
  String get selectExpenseTypeFirst =>
      'Mai întâi selectează tipul de cheltuială';

  @override
  String get errorLoadingCategories => 'Eroare la încărcarea categoriilor';

  @override
  String get queryMonth => 'Luna de interogare';

  @override
  String get remainingAmount => 'Sumă rămasă';

  @override
  String get todayExpenseMessageZero =>
      'Înregistrează-ți cheltuielile de azi 😊';

  @override
  String get todayExpenseMessageGood => 'Excelent! Mai ai mult buget rămas 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Ai folosit aproape jumătate! Hai să fim mai atenți acum 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Ești aproape de a depăși bugetul de azi! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Ai depășit bugetul de azi! Hai să ajustăm cheltuielile ❗';

  @override
  String get information => 'Informații';

  @override
  String get writeReview => 'Scrie recenzie';

  @override
  String get appVersion => 'Versiune aplicație';

  @override
  String get privacyPolicy => 'Politica de confidențialitate';

  @override
  String get basicSettings => 'Setări de bază';

  @override
  String get titleAndClose => 'Titlu și închide';

  @override
  String get filterSettings => 'Setări filtre';

  @override
  String get sort => 'Sortează';

  @override
  String get latest => 'Cele mai recente';

  @override
  String get oldest => 'Cele mai vechi';

  @override
  String get statistics => 'Statistici';

  @override
  String get spendingByCategory => 'Cheltuieli pe categorii';

  @override
  String get top3ExpensesThisMonth => 'Top 3 cheltuieli luna aceasta';

  @override
  String get home => 'Acasă';

  @override
  String get daily => 'Zilnic';

  @override
  String get monthly => 'Lunar';

  @override
  String get calendar => 'Calendar';

  @override
  String get stats => 'Statistici';

  @override
  String get expense => 'Cheltuieli';

  @override
  String get settings => 'Setări';

  @override
  String get notificationTitleDaily => 'Memento cheltuieli zilnice';

  @override
  String get notificationBodyMorning =>
      'Bună dimineața! ☀️ Gata să înregistrezi prima cheltuială a zilei? Obiceiurile mici fac o mare diferență!';

  @override
  String get notificationBodyAfternoon =>
      'Prânz bun? 🍱 Ce zici de o actualizare rapidă a cheltuielilor?';

  @override
  String get notificationBodyNight =>
      'Ziua aproape s-a terminat 🌙 Încheie-o organizându-ți cheltuielile.';

  @override
  String get resetComplete => 'Mulțumim că ai folosit MoneyFit.';

  @override
  String get upgraderTitle => 'Actualizare disponibilă';

  @override
  String get upgraderBody =>
      'O nouă versiune a aplicației este disponibilă. Te rugăm să actualizezi pentru o experiență mai bună.';

  @override
  String get upgraderPrompt => 'Vrei să actualizezi acum?';

  @override
  String get upgraderButtonLater => 'Mai târziu';

  @override
  String get upgraderButtonUpdate => 'Actualizează acum';

  @override
  String get upgraderButtonIgnore => 'Ignoră';

  @override
  String get updateRequiredTitle => 'Actualizare necesară';

  @override
  String get updateRequiredBody =>
      'Te rugăm să actualizezi la cea mai recentă versiune pentru cea mai bună experiență.';

  @override
  String get updateAvailableBody =>
      'O nouă versiune este disponibilă. Bucură-te de cele mai noi funcții și îmbunătățiri.';

  @override
  String get updateChangelogTitle => 'Ce este nou';

  @override
  String get updateButton => 'Actualizează';

  @override
  String get updateDetails => 'Detalii';

  @override
  String get updateSheetTitle => 'Info actualizare';

  @override
  String get updateButtonGo => 'Mergi la actualizare';

  @override
  String get review_modal_binary_title =>
      'Ești mulțumit de aplicație până acum?';

  @override
  String get review_modal_button_good => 'Mi-a plăcut';

  @override
  String get review_modal_button_bad => 'Nu prea';

  @override
  String get review_positive_title => 'Ne poți spune ce ți-a plăcut?';

  @override
  String get review_positive_button_yes => 'Sigur';

  @override
  String get review_button_later => 'Mai târziu';

  @override
  String get review_button_never => 'Nu mai arăta';

  @override
  String get review_negative_title =>
      'Spune-ne ce nu a funcționat pentru tine.';

  @override
  String get review_negative_hint => 'Spune-ne ce a fost incomod.';

  @override
  String get review_negative_button_send => 'Trimite';

  @override
  String get review_thanks_message =>
      'Mulțumim pentru feedback. Vom lucra să îmbunătățim.';

  @override
  String get monthlyExpenseMessageZero =>
      'Nicio cheltuială discreționară luna aceasta încă!';

  @override
  String get monthlyExpenseMessageGood =>
      'Bugetul tău este bine gestionat luna aceasta!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Ai folosit aproximativ jumătate din buget luna aceasta.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Bugetul tău este aproape epuizat luna aceasta.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Ai depășit bugetul luna aceasta.';

  @override
  String get contactUs => 'Contactează-ne';

  @override
  String get inquiryType => 'Tip întrebare';

  @override
  String get inquiryTypeBugReport => 'Raport eroare';

  @override
  String get inquiryTypeFeatureSuggestion => 'Sugestie funcție';

  @override
  String get inquiryTypeGeneralInquiry => 'Întrebare generală';

  @override
  String get inquiryTypeOther => 'Altele';

  @override
  String get replyEmail => 'Email pentru răspuns';

  @override
  String get optional => 'Opțional';

  @override
  String get inquiryDetails => 'Detalii întrebare';

  @override
  String get submit => 'Trimite';

  @override
  String get inquirySuccess => 'Întrebarea ta a fost trimisă cu succes.';

  @override
  String get inquiryFailure => 'Nu s-a putut trimite întrebarea.';

  @override
  String get invalidEmail => 'Te rugăm să introduci o adresă de email validă.';

  @override
  String get fieldRequired => 'Acest câmp este obligatoriu.';

  @override
  String get selectThemeColor => 'Selectează culoarea temei';

  @override
  String get quickSelect => 'Selecție rapidă';

  @override
  String get recentColors => 'Culori recente';

  @override
  String get customSelect => 'Selecție personalizată';

  @override
  String get close => 'Închide';

  @override
  String get languageSetting => 'Limbă și monedă';

  @override
  String get selectLanguage => 'Selectează limba';
}
