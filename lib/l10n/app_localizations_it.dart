// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Basta con i fogli di calcolo complicati';

  @override
  String get onboardingDescription1 =>
      'Gestisci facilmente le tue spese quotidiane e crea abitudini di spesa sane.';

  @override
  String get onboardingTitle2 => 'Budget giornaliero a colpo d\'occhio';

  @override
  String get onboardingDescription2 =>
      'Tieni traccia del budget rimanente per oggi e inizia a spendere consapevolmente.';

  @override
  String get onboardingTitle3 => 'Trasforma i successi in abitudini durature';

  @override
  String get onboardingDescription3 =>
      'Trasforma le sfide quotidiane in successi e goditi la gestione del denaro.';

  @override
  String get next => 'Avanti';

  @override
  String get dailyBudgetSetupTitle => 'Imposta il budget';

  @override
  String get budgetSetupDescription =>
      'Imposta il budget per le spese discrezionali. Le spese discrezionali sono l\'importo che puoi usare liberamente, esclusi i costi fissi come bollette, spese mediche, alloggio e assicurazione.';

  @override
  String get dailyBudgetLabel => 'Budget giornaliero';

  @override
  String get monthlyBudgetLabel => 'Budget mensile';

  @override
  String get enterBudgetPrompt => 'Inserisci il tuo budget.';

  @override
  String get enterValidNumberPrompt => 'Inserisci un numero valido.';

  @override
  String get budgetGreaterThanZeroPrompt =>
      'Il budget deve essere maggiore di 0.';

  @override
  String get start => 'Inizia';

  @override
  String errorOccurred(Object error) {
    return 'Si è verificato un errore: $error';
  }

  @override
  String get dateFormat => 'EEEE d MMMM yyyy';

  @override
  String get dailyDiscretionarySpending => 'Spese discrezionali giornaliere: ';

  @override
  String get monthlyDiscretionarySpending2 => 'Spese discrezionali mensili: ';

  @override
  String get dailyBudget => 'Budget discrezionale giornaliero: ';

  @override
  String get monthlyBudget => 'Budget discrezionale mensile: ';

  @override
  String get monthlyAvgDiscSpending => 'Discr/Giorno (Mese)';

  @override
  String get consecutiveDays => 'Serie di successi';

  @override
  String days(Object count) {
    return '$count giorni';
  }

  @override
  String get viewTodaySpending => 'Vedi spese\ndi oggi';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spese',
      one: '1 spesa',
      zero: 'Nessuna spesa ancora',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Aggiungi\nspesa di oggi';

  @override
  String get addNewExpensePrompt => 'Aggiungi una nuova spesa';

  @override
  String get notificationDialogTitle =>
      'Ti aiuteremo a ricordare di registrare le spese';

  @override
  String get notificationDialogDescription =>
      'Registrare le spese è facile, ma è anche facile dimenticarsene. Ti invieremo promemoria giornalieri. Vuoi ricevere notifiche?';

  @override
  String get notificationDialogDeny => 'No, grazie';

  @override
  String get notificationDialogConfirm => 'Sì, grazie';

  @override
  String get category_food => 'Cibo';

  @override
  String get category_traffic => 'Trasporti';

  @override
  String get category_insurance => 'Assicurazione';

  @override
  String get category_necessities => 'Necessità';

  @override
  String get category_communication => 'Comunicazione';

  @override
  String get category_housing => 'Alloggio/Utenze';

  @override
  String get category_medical => 'Medico';

  @override
  String get category_finance => 'Finanza';

  @override
  String get categoryEatingOut => 'Mangiare fuori';

  @override
  String get category_cafe => 'Caffè/Snack';

  @override
  String get category_shopping => 'Shopping';

  @override
  String get category_hobby => 'Hobby/Tempo libero';

  @override
  String get category_travel => 'Viaggi/Relax';

  @override
  String get category_subscribe => 'Abbonamenti';

  @override
  String get category_beauty => 'Bellezza';

  @override
  String get expenseType_essential => 'Essenziale';

  @override
  String get expenseType_discretionary => 'Discrezionale';

  @override
  String get dailyExpenseHistory => 'Storico spese giornaliere';

  @override
  String get noExpenseHistory => 'Nessuno storico spese trovato.';

  @override
  String get editDeleteExpense => 'Modifica/Elimina spesa';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Cosa vuoi fare con la spesa \"$expenseName\"?';
  }

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String get allExpenses => 'Tutte le spese';

  @override
  String get allCategories => 'Tutte le categorie';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get ascending => 'Crescente';

  @override
  String get descending => 'Decrescente';

  @override
  String get noExpenseData => 'Nessun dato sulle spese';

  @override
  String get changeFilterPrompt =>
      'Prova a cambiare i filtri o aggiungi una nuova spesa';

  @override
  String get allFieldsRequired => 'Compila tutti i campi correttamente.';

  @override
  String get addNewCategory => 'Aggiungi nuova categoria';

  @override
  String get cancel => 'Annulla';

  @override
  String get add => 'Aggiungi';

  @override
  String get deleteCategory => 'Elimina categoria';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Sei sicuro di voler eliminare la categoria \'$categoryName\'?';
  }

  @override
  String get pleaseWait => 'Attendere prego...';

  @override
  String get noDataExists => 'Nessun dato presente.';

  @override
  String get reset => 'Reimposta';

  @override
  String get selectDate => 'Seleziona data';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Conferma';

  @override
  String get budgetSetting => 'Impostazione budget';

  @override
  String get save => 'Salva';

  @override
  String get resetInformation => 'Reimposta informazioni';

  @override
  String get notificationPermissionRequired => 'Permesso notifiche richiesto';

  @override
  String get notificationPermissionDescription =>
      'Per usare le notifiche, abilitale nelle impostazioni.';

  @override
  String get goToSettings => 'Vai alle Impostazioni';

  @override
  String get monthlyDiscretionarySpending => 'Discrezionale';

  @override
  String get monthlyEssentialSpending => 'Essenziale';

  @override
  String get success => 'Successo';

  @override
  String get failure => 'Fallimento';

  @override
  String get consecutiveSuccess => 'Serie';

  @override
  String daysCount(Object count) {
    return '$count giorni';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Il nome è vuoto.';

  @override
  String get invalidAmount =>
      'L\'importo non è valido o è minore o uguale a 0.';

  @override
  String get categoryNotSelected => 'Categoria non selezionata.';

  @override
  String formValidationError(Object error) {
    return 'Errore di validazione: $error';
  }

  @override
  String get registerExpense => 'Registra spesa';

  @override
  String get register => 'Registra';

  @override
  String get date => 'Data';

  @override
  String get expenseName => 'Nome spesa';

  @override
  String get enterExpenseName => 'Inserisci il nome della spesa';

  @override
  String get amount => 'Importo';

  @override
  String get enterExpenseAmount => 'Inserisci l\'importo della spesa';

  @override
  String get expenseType => 'Tipo di spesa';

  @override
  String get essentialExpense => 'Essenziale';

  @override
  String get discretionaryExpense => 'Discrezionale';

  @override
  String get categoryName => 'Nome categoria';

  @override
  String get sunday => 'Dom';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Mer';

  @override
  String get thursday => 'Gio';

  @override
  String get friday => 'Ven';

  @override
  String get saturday => 'Sab';

  @override
  String errorWithMessage(Object error) {
    return 'Errore: $error';
  }

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get themeColor => 'Colore tema';

  @override
  String get themeColorDescription => 'Personalizza lo schema colori dell\'app';

  @override
  String get fontSize => 'Dimensione carattere';

  @override
  String get fontSizeDescription =>
      'Regola la dimensione del testo per una migliore leggibilità';

  @override
  String get fontSizeSmall => 'Piccolo';

  @override
  String get fontSizeMedium => 'Medio';

  @override
  String get fontSizeLarge => 'Grande';

  @override
  String get apply => 'Applica';

  @override
  String get dataManagement => 'Gestione dati';

  @override
  String get resetDataConfirmation =>
      'Sei sicuro di voler reimpostare tutti i dati? Questa azione non può essere annullata.';

  @override
  String get notificationSetting => 'Impostazione notifiche';

  @override
  String get category => 'Categoria';

  @override
  String get selectExpenseTypeFirst => 'Prima seleziona il tipo di spesa';

  @override
  String get errorLoadingCategories => 'Errore nel caricamento delle categorie';

  @override
  String get queryMonth => 'Mese di ricerca';

  @override
  String get remainingAmount => 'Importo rimanente';

  @override
  String get todayExpenseMessageZero => 'Registra le tue spese di oggi 😊';

  @override
  String get todayExpenseMessageGood => 'Ottimo! Hai ancora molto budget 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Hai usato quasi la metà! Siamo più attenti ora 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Stai per superare il budget di oggi! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Hai superato il budget di oggi! Regoliamo le spese ❗';

  @override
  String get information => 'Informazioni';

  @override
  String get writeReview => 'Scrivi recensione';

  @override
  String get appVersion => 'Versione app';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get basicSettings => 'Impostazioni di base';

  @override
  String get titleAndClose => 'Titolo e chiudi';

  @override
  String get filterSettings => 'Impostazioni filtri';

  @override
  String get sort => 'Ordina';

  @override
  String get latest => 'Più recenti';

  @override
  String get oldest => 'Più vecchi';

  @override
  String get statistics => 'Statistiche';

  @override
  String get spendingByCategory => 'Spese per categoria';

  @override
  String get top3ExpensesThisMonth => 'Top 3 spese questo mese';

  @override
  String get home => 'Home';

  @override
  String get daily => 'Giornaliero';

  @override
  String get monthly => 'Mensile';

  @override
  String get calendar => 'Calendario';

  @override
  String get stats => 'Statistiche';

  @override
  String get expense => 'Spese';

  @override
  String get settings => 'Impostazioni';

  @override
  String get notificationTitleDaily => 'Promemoria spese giornaliere';

  @override
  String get notificationBodyMorning =>
      'Buongiorno! ☀️ Pronto a registrare la prima spesa del giorno? Le piccole abitudini fanno una grande differenza!';

  @override
  String get notificationBodyAfternoon =>
      'Buon pranzo? 🍱 Che ne dici di un rapido aggiornamento delle spese?';

  @override
  String get notificationBodyNight =>
      'La giornata sta per finire 🌙 Concludila organizzando le tue spese.';

  @override
  String get resetComplete => 'Grazie per aver usato MoneyFit.';

  @override
  String get upgraderTitle => 'Aggiornamento disponibile';

  @override
  String get upgraderBody =>
      'È disponibile una nuova versione dell\'app. Aggiorna per un\'esperienza migliore.';

  @override
  String get upgraderPrompt => 'Vuoi aggiornare ora?';

  @override
  String get upgraderButtonLater => 'Più tardi';

  @override
  String get upgraderButtonUpdate => 'Aggiorna ora';

  @override
  String get upgraderButtonIgnore => 'Ignora';

  @override
  String get updateRequiredTitle => 'Aggiornamento richiesto';

  @override
  String get updateRequiredBody =>
      'Aggiorna all\'ultima versione per la migliore esperienza.';

  @override
  String get updateAvailableBody =>
      'È disponibile una nuova versione. Goditi le ultime funzionalità e miglioramenti.';

  @override
  String get updateChangelogTitle => 'Novità';

  @override
  String get updateButton => 'Aggiorna';

  @override
  String get updateDetails => 'Dettagli';

  @override
  String get updateSheetTitle => 'Info aggiornamento';

  @override
  String get updateButtonGo => 'Vai all\'aggiornamento';

  @override
  String get review_modal_binary_title => 'Sei soddisfatto dell\'app finora?';

  @override
  String get review_modal_button_good => 'Mi è piaciuta';

  @override
  String get review_modal_button_bad => 'Non molto';

  @override
  String get review_positive_title => 'Puoi dirci cosa ti è piaciuto?';

  @override
  String get review_positive_button_yes => 'Certo';

  @override
  String get review_button_later => 'Più tardi';

  @override
  String get review_button_never => 'Non mostrare più';

  @override
  String get review_negative_title => 'Dicci cosa non ha funzionato per te.';

  @override
  String get review_negative_hint => 'Dicci cosa è stato scomodo.';

  @override
  String get review_negative_button_send => 'Invia';

  @override
  String get review_thanks_message =>
      'Grazie per il feedback. Lavoreremo per migliorare.';

  @override
  String get monthlyExpenseMessageZero =>
      'Nessuna spesa discrezionale questo mese ancora!';

  @override
  String get monthlyExpenseMessageGood =>
      'Il tuo budget è ben gestito questo mese!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Hai usato circa metà del budget questo mese.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Il tuo budget è quasi esaurito questo mese.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Hai superato il budget questo mese.';

  @override
  String get contactUs => 'Contattaci';

  @override
  String get inquiryType => 'Tipo di richiesta';

  @override
  String get inquiryTypeBugReport => 'Segnalazione bug';

  @override
  String get inquiryTypeFeatureSuggestion => 'Suggerimento funzionalità';

  @override
  String get inquiryTypeGeneralInquiry => 'Richiesta generale';

  @override
  String get inquiryTypeOther => 'Altro';

  @override
  String get replyEmail => 'Email per risposta';

  @override
  String get optional => 'Opzionale';

  @override
  String get inquiryDetails => 'Dettagli richiesta';

  @override
  String get submit => 'Invia';

  @override
  String get inquirySuccess => 'La tua richiesta è stata inviata con successo.';

  @override
  String get inquiryFailure => 'Impossibile inviare la richiesta.';

  @override
  String get invalidEmail => 'Inserisci un indirizzo email valido.';

  @override
  String get fieldRequired => 'Questo campo è obbligatorio.';

  @override
  String get selectThemeColor => 'Seleziona colore tema';

  @override
  String get quickSelect => 'Selezione rapida';

  @override
  String get recentColors => 'Colori recenti';

  @override
  String get customSelect => 'Selezione personalizzata';

  @override
  String get close => 'Chiudi';

  @override
  String get languageSetting => 'Lingua e valuta';

  @override
  String get selectLanguage => 'Seleziona lingua';
}
