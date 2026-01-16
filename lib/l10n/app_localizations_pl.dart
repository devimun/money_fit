// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Koniec ze skomplikowanymi arkuszami';

  @override
  String get onboardingDescription1 =>
      'Łatwo zarządzaj codziennymi wydatkami i buduj zdrowe nawyki finansowe.';

  @override
  String get onboardingTitle2 => 'Dzienny budżet na pierwszy rzut oka';

  @override
  String get onboardingDescription2 =>
      'Śledź pozostały budżet na dziś i zacznij wydawać świadomie.';

  @override
  String get onboardingTitle3 => 'Zamień osiągnięcia w trwałe nawyki';

  @override
  String get onboardingDescription3 =>
      'Przekształć codzienne wyzwania w osiągnięcia i ciesz się zarządzaniem pieniędzmi.';

  @override
  String get next => 'Dalej';

  @override
  String get dailyBudgetSetupTitle => 'Ustaw swój budżet';

  @override
  String get budgetSetupDescription =>
      'Ustaw budżet na wydatki uznaniowe. Wydatki uznaniowe to kwota, którą możesz swobodnie wykorzystać, z wyłączeniem stałych kosztów jak rachunki, wydatki medyczne, mieszkanie i ubezpieczenia.';

  @override
  String get dailyBudgetLabel => 'Budżet dzienny';

  @override
  String get monthlyBudgetLabel => 'Budżet miesięczny';

  @override
  String get enterBudgetPrompt => 'Wprowadź swój budżet.';

  @override
  String get enterValidNumberPrompt => 'Wprowadź prawidłową liczbę.';

  @override
  String get budgetGreaterThanZeroPrompt => 'Budżet musi być większy niż 0.';

  @override
  String get start => 'Rozpocznij';

  @override
  String errorOccurred(Object error) {
    return 'Wystąpił błąd: $error';
  }

  @override
  String get dateFormat => 'd MMMM yyyy, EEEE';

  @override
  String get dailyDiscretionarySpending => 'Dzienne wydatki uznaniowe: ';

  @override
  String get monthlyDiscretionarySpending2 => 'Miesięczne wydatki uznaniowe: ';

  @override
  String get dailyBudget => 'Dzienny budżet uznaniowy: ';

  @override
  String get monthlyBudget => 'Miesięczny budżet uznaniowy: ';

  @override
  String get monthlyAvgDiscSpending => 'Uzn/Dzień (Mies.)';

  @override
  String get consecutiveDays => 'Seria sukcesów';

  @override
  String days(Object count) {
    return '$count dni';
  }

  @override
  String get viewTodaySpending => 'Zobacz wydatki\nz dzisiaj';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wydatków',
      few: '$count wydatki',
      one: '1 wydatek',
      zero: 'Brak wydatków',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Dodaj\nwydatek z dzisiaj';

  @override
  String get addNewExpensePrompt => 'Dodaj nowy wydatek';

  @override
  String get notificationDialogTitle =>
      'Pomożemy Ci pamiętać o zapisywaniu wydatków';

  @override
  String get notificationDialogDescription =>
      'Zapisywanie wydatków jest łatwe, ale też łatwo o tym zapomnieć. Wyślemy Ci codzienne przypomnienia. Czy chcesz otrzymywać powiadomienia?';

  @override
  String get notificationDialogDeny => 'Nie, dziękuję';

  @override
  String get notificationDialogConfirm => 'Tak, proszę';

  @override
  String get category_food => 'Jedzenie';

  @override
  String get category_traffic => 'Transport';

  @override
  String get category_insurance => 'Ubezpieczenia';

  @override
  String get category_necessities => 'Artykuły pierwszej potrzeby';

  @override
  String get category_communication => 'Komunikacja';

  @override
  String get category_housing => 'Mieszkanie/Media';

  @override
  String get category_medical => 'Medyczne';

  @override
  String get category_finance => 'Finanse';

  @override
  String get categoryEatingOut => 'Jedzenie na mieście';

  @override
  String get category_cafe => 'Kawiarnia/Przekąski';

  @override
  String get category_shopping => 'Zakupy';

  @override
  String get category_hobby => 'Hobby/Rozrywka';

  @override
  String get category_travel => 'Podróże/Odpoczynek';

  @override
  String get category_subscribe => 'Subskrypcje';

  @override
  String get category_beauty => 'Uroda';

  @override
  String get expenseType_essential => 'Niezbędne';

  @override
  String get expenseType_discretionary => 'Uznaniowe';

  @override
  String get dailyExpenseHistory => 'Historia wydatków dziennych';

  @override
  String get noExpenseHistory => 'Nie znaleziono historii wydatków.';

  @override
  String get editDeleteExpense => 'Edytuj/Usuń wydatek';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Co chcesz zrobić z wydatkiem \"$expenseName\"?';
  }

  @override
  String get edit => 'Edytuj';

  @override
  String get delete => 'Usuń';

  @override
  String get allExpenses => 'Wszystkie wydatki';

  @override
  String get allCategories => 'Wszystkie kategorie';

  @override
  String get unknown => 'Nieznane';

  @override
  String get ascending => 'Rosnąco';

  @override
  String get descending => 'Malejąco';

  @override
  String get noExpenseData => 'Brak danych o wydatkach';

  @override
  String get changeFilterPrompt =>
      'Spróbuj zmienić filtry lub dodaj nowy wydatek';

  @override
  String get allFieldsRequired => 'Wypełnij wszystkie pola poprawnie.';

  @override
  String get addNewCategory => 'Dodaj nową kategorię';

  @override
  String get cancel => 'Anuluj';

  @override
  String get add => 'Dodaj';

  @override
  String get deleteCategory => 'Usuń kategorię';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Czy na pewno chcesz usunąć kategorię \'$categoryName\'?';
  }

  @override
  String get pleaseWait => 'Proszę czekać...';

  @override
  String get noDataExists => 'Brak danych.';

  @override
  String get reset => 'Resetuj';

  @override
  String get selectDate => 'Wybierz datę';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Potwierdź';

  @override
  String get budgetSetting => 'Ustawienia budżetu';

  @override
  String get save => 'Zapisz';

  @override
  String get resetInformation => 'Resetuj informacje';

  @override
  String get notificationPermissionRequired =>
      'Wymagane uprawnienie do powiadomień';

  @override
  String get notificationPermissionDescription =>
      'Aby korzystać z powiadomień, zezwól na nie w ustawieniach.';

  @override
  String get goToSettings => 'Przejdź do Ustawień';

  @override
  String get monthlyDiscretionarySpending => 'Uznaniowe';

  @override
  String get monthlyEssentialSpending => 'Niezbędne';

  @override
  String get success => 'Sukces';

  @override
  String get failure => 'Porażka';

  @override
  String get consecutiveSuccess => 'Seria';

  @override
  String daysCount(Object count) {
    return '$count dni';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Nazwa jest pusta.';

  @override
  String get invalidAmount =>
      'Kwota jest nieprawidłowa lub mniejsza lub równa 0.';

  @override
  String get categoryNotSelected => 'Nie wybrano kategorii.';

  @override
  String formValidationError(Object error) {
    return 'Błąd walidacji: $error';
  }

  @override
  String get registerExpense => 'Zarejestruj wydatek';

  @override
  String get register => 'Zarejestruj';

  @override
  String get date => 'Data';

  @override
  String get expenseName => 'Nazwa wydatku';

  @override
  String get enterExpenseName => 'Wprowadź nazwę wydatku';

  @override
  String get amount => 'Kwota';

  @override
  String get enterExpenseAmount => 'Wprowadź kwotę wydatku';

  @override
  String get expenseType => 'Typ wydatku';

  @override
  String get essentialExpense => 'Niezbędny';

  @override
  String get discretionaryExpense => 'Uznaniowy';

  @override
  String get categoryName => 'Nazwa kategorii';

  @override
  String get sunday => 'Nd';

  @override
  String get monday => 'Pn';

  @override
  String get tuesday => 'Wt';

  @override
  String get wednesday => 'Śr';

  @override
  String get thursday => 'Cz';

  @override
  String get friday => 'Pt';

  @override
  String get saturday => 'Sb';

  @override
  String errorWithMessage(Object error) {
    return 'Błąd: $error';
  }

  @override
  String get darkMode => 'Tryb ciemny';

  @override
  String get themeColor => 'Kolor motywu';

  @override
  String get themeColorDescription => 'Dostosuj schemat kolorów aplikacji';

  @override
  String get fontSize => 'Rozmiar czcionki';

  @override
  String get fontSizeDescription =>
      'Dostosuj rozmiar tekstu dla lepszej czytelności';

  @override
  String get fontSizeSmall => 'Mały';

  @override
  String get fontSizeMedium => 'Średni';

  @override
  String get fontSizeLarge => 'Duży';

  @override
  String get apply => 'Zastosuj';

  @override
  String get dataManagement => 'Zarządzanie danymi';

  @override
  String get resetDataConfirmation =>
      'Czy na pewno chcesz zresetować wszystkie dane? Tej operacji nie można cofnąć.';

  @override
  String get notificationSetting => 'Ustawienia powiadomień';

  @override
  String get category => 'Kategoria';

  @override
  String get selectExpenseTypeFirst => 'Najpierw wybierz typ wydatku';

  @override
  String get errorLoadingCategories => 'Błąd ładowania kategorii';

  @override
  String get queryMonth => 'Miesiąc zapytania';

  @override
  String get remainingAmount => 'Pozostała kwota';

  @override
  String get todayExpenseMessageZero => 'Zapisz swoje wydatki z dzisiaj 😊';

  @override
  String get todayExpenseMessageGood =>
      'Świetnie! Masz jeszcze sporo budżetu 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Wykorzystałeś prawie połowę! Bądźmy teraz bardziej ostrożni 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Jesteś blisko przekroczenia dzisiejszego budżetu! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Przekroczyłeś dzisiejszy budżet! Dostosujmy wydatki ❗';

  @override
  String get information => 'Informacje';

  @override
  String get writeReview => 'Napisz recenzję';

  @override
  String get appVersion => 'Wersja aplikacji';

  @override
  String get privacyPolicy => 'Polityka prywatności';

  @override
  String get basicSettings => 'Ustawienia podstawowe';

  @override
  String get titleAndClose => 'Tytuł i zamknij';

  @override
  String get filterSettings => 'Ustawienia filtrów';

  @override
  String get sort => 'Sortuj';

  @override
  String get latest => 'Najnowsze';

  @override
  String get oldest => 'Najstarsze';

  @override
  String get statistics => 'Statystyki';

  @override
  String get spendingByCategory => 'Wydatki według kategorii';

  @override
  String get top3ExpensesThisMonth => 'Top 3 wydatki w tym miesiącu';

  @override
  String get home => 'Główna';

  @override
  String get daily => 'Dziennie';

  @override
  String get monthly => 'Miesięcznie';

  @override
  String get calendar => 'Kalendarz';

  @override
  String get stats => 'Statystyki';

  @override
  String get expense => 'Wydatki';

  @override
  String get settings => 'Ustawienia';

  @override
  String get notificationTitleDaily => 'Przypomnienie o wydatkach';

  @override
  String get notificationBodyMorning =>
      'Dzień dobry! ☀️ Gotowy zapisać pierwszy wydatek dnia? Małe nawyki robią wielką różnicę!';

  @override
  String get notificationBodyAfternoon =>
      'Smaczny obiad? 🍱 Co powiesz na szybką aktualizację wydatków?';

  @override
  String get notificationBodyNight =>
      'Dzień prawie się kończy 🌙 Zakończ go porządkując wydatki.';

  @override
  String get resetComplete => 'Dziękujemy za korzystanie z MoneyFit.';

  @override
  String get upgraderTitle => 'Dostępna aktualizacja';

  @override
  String get upgraderBody =>
      'Dostępna jest nowa wersja aplikacji. Zaktualizuj dla lepszego doświadczenia.';

  @override
  String get upgraderPrompt => 'Czy chcesz zaktualizować teraz?';

  @override
  String get upgraderButtonLater => 'Później';

  @override
  String get upgraderButtonUpdate => 'Aktualizuj teraz';

  @override
  String get upgraderButtonIgnore => 'Ignoruj';

  @override
  String get updateRequiredTitle => 'Wymagana aktualizacja';

  @override
  String get updateRequiredBody =>
      'Zaktualizuj do najnowszej wersji dla najlepszego doświadczenia.';

  @override
  String get updateAvailableBody =>
      'Dostępna jest nowa wersja. Ciesz się najnowszymi funkcjami i ulepszeniami.';

  @override
  String get updateChangelogTitle => 'Co nowego';

  @override
  String get updateButton => 'Aktualizuj';

  @override
  String get updateDetails => 'Szczegóły';

  @override
  String get updateSheetTitle => 'Info o aktualizacji';

  @override
  String get updateButtonGo => 'Przejdź do aktualizacji';

  @override
  String get review_modal_binary_title => 'Czy jesteś zadowolony z aplikacji?';

  @override
  String get review_modal_button_good => 'Podoba mi się';

  @override
  String get review_modal_button_bad => 'Nie bardzo';

  @override
  String get review_positive_title =>
      'Czy możesz nam powiedzieć, co Ci się podobało?';

  @override
  String get review_positive_button_yes => 'Jasne';

  @override
  String get review_button_later => 'Później';

  @override
  String get review_button_never => 'Nie pokazuj ponownie';

  @override
  String get review_negative_title => 'Powiedz nam, co Ci nie odpowiadało.';

  @override
  String get review_negative_hint => 'Powiedz nam, co było niewygodne.';

  @override
  String get review_negative_button_send => 'Wyślij';

  @override
  String get review_thanks_message =>
      'Dziękujemy za opinię. Postaramy się to poprawić.';

  @override
  String get monthlyExpenseMessageZero =>
      'Brak wydatków uznaniowych w tym miesiącu!';

  @override
  String get monthlyExpenseMessageGood =>
      'Twój budżet jest dobrze zarządzany w tym miesiącu!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Wykorzystałeś około połowy budżetu w tym miesiącu.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Twój budżet jest prawie wyczerpany w tym miesiącu.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Przekroczyłeś budżet w tym miesiącu.';

  @override
  String get contactUs => 'Skontaktuj się z nami';

  @override
  String get inquiryType => 'Typ zapytania';

  @override
  String get inquiryTypeBugReport => 'Zgłoszenie błędu';

  @override
  String get inquiryTypeFeatureSuggestion => 'Sugestia funkcji';

  @override
  String get inquiryTypeGeneralInquiry => 'Ogólne zapytanie';

  @override
  String get inquiryTypeOther => 'Inne';

  @override
  String get replyEmail => 'Email do odpowiedzi';

  @override
  String get optional => 'Opcjonalne';

  @override
  String get inquiryDetails => 'Szczegóły zapytania';

  @override
  String get submit => 'Wyślij';

  @override
  String get inquirySuccess => 'Twoje zapytanie zostało pomyślnie wysłane.';

  @override
  String get inquiryFailure => 'Nie udało się wysłać zapytania.';

  @override
  String get invalidEmail => 'Wprowadź prawidłowy adres email.';

  @override
  String get fieldRequired => 'To pole jest wymagane.';

  @override
  String get selectThemeColor => 'Wybierz kolor motywu';

  @override
  String get quickSelect => 'Szybki wybór';

  @override
  String get recentColors => 'Ostatnie kolory';

  @override
  String get customSelect => 'Własny wybór';

  @override
  String get close => 'Zamknij';

  @override
  String get languageSetting => 'Język i waluta';

  @override
  String get selectLanguage => 'Wybierz język';
}
