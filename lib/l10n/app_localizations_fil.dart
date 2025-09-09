// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Wala Nang Kumplikadong Spreadsheet';

  @override
  String get onboardingDescription1 =>
      'Madaling pamahalaan ang iyong pang-araw-araw na gastos at\nbumuo ng malusog na gawi sa paggastos.';

  @override
  String get onboardingTitle2 => 'Badyet sa Isang Sulyap';

  @override
  String get onboardingDescription2 =>
      'Subaybayan ang iyong natitirang badyet para sa araw at\nsimulan ang maingat na paggastos.';

  @override
  String get onboardingTitle3 => 'Gawing Gawi ang mga Nakamit';

  @override
  String get onboardingDescription3 =>
      'Gawing mga nakamit ang pang-araw-araw na hamon at\nmag-enjoy sa pamamahala ng iyong pera.';

  @override
  String get next => 'Susunod';

  @override
  String get dailyBudgetSetupTitle => 'Itakda ang Iyong Badyet';

  @override
  String get budgetSetupDescription =>
      'Itakda ang iyong budget para sa gastusing flexible.\nIto ang halaga na malaya mong magagamit, hindi kasama ang mga bayarin, gastusing medikal, pabahay, at insurance.';

  @override
  String get dailyBudgetLabel => 'Arawang Badyet (PHP)';

  @override
  String get monthlyBudgetLabel => 'Badyet Buwanang (PHP)';

  @override
  String get enterBudgetPrompt => 'Ilagay ang iyong badyet.';

  @override
  String get enterValidNumberPrompt => 'Maglagay ng wastong numero.';

  @override
  String get budgetGreaterThanZeroPrompt => 'Dapat mas malaki sa 0 ang badyet.';

  @override
  String get start => 'Magsimula';

  @override
  String errorOccurred(Object error) {
    return 'Nagkaroon ng error: $error';
  }

  @override
  String get dateFormat => 'MMMM d, yyyy EEEE';

  @override
  String get dailyDiscretionarySpending =>
      'Araw-araw na Gastusing Diskresyonaryo: ';

  @override
  String get monthlyDiscretionarySpending2 =>
      'Buwanang Gastusing Diskresyonaryo: ';

  @override
  String get dailyBudget => 'Araw-araw na Badyet na Diskresyonaryo: ';

  @override
  String get monthlyBudget => 'Buwanang Badyet na Diskresyonaryo: ';

  @override
  String get monthlyAvgDiscSpending => 'Gastos/Araw (Buwan)';

  @override
  String get consecutiveDays => 'Sunod-sunod na Tagumpay';

  @override
  String days(Object count) {
    return '$count araw';
  }

  @override
  String get currency => '₱';

  @override
  String get viewTodaySpending => 'Tingnan ang\nGastos Ngayon';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count na gastos',
      one: '1 gastos',
      zero: 'Wala pang gastos',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Idagdag ang\nGastos Ngayon';

  @override
  String get addNewExpensePrompt => 'Magdagdag ng bagong gastos';

  @override
  String get notificationDialogTitle => 'Paalala sa Pag-log ng Gastos';

  @override
  String get notificationDialogDescription =>
      'Madali ang pag-log ng gastos, pero madali ring makalimutan.\nMagpapadala kami ng arawang paalala. Gusto mo bang makatanggap ng notifications?';

  @override
  String get notificationDialogDeny => 'Huwag na lang';

  @override
  String get notificationDialogConfirm => 'Oo';

  @override
  String get category_food => 'Pagkain';

  @override
  String get category_traffic => 'Transportasyon';

  @override
  String get category_insurance => 'Insurance';

  @override
  String get category_necessities => 'Pangangailangan';

  @override
  String get category_communication => 'Komunikasyon';

  @override
  String get category_housing => 'Pabahay/Utility';

  @override
  String get category_medical => 'Medikal';

  @override
  String get category_finance => 'Pananalapi';

  @override
  String get categoryEatingOut => 'Kain sa Labas';

  @override
  String get category_cafe => 'Cafe/Meryenda';

  @override
  String get category_shopping => 'Shopping';

  @override
  String get category_hobby => 'Libangan';

  @override
  String get category_travel => 'Biyahe/Pahinga';

  @override
  String get category_subscribe => 'Subskripsyon';

  @override
  String get category_beauty => 'Kagandahan';

  @override
  String get expenseType_essential => 'Mahalaga';

  @override
  String get expenseType_discretionary => 'Flexible';

  @override
  String get dailyExpenseHistory => 'Kasaysayan ng Arawang Gastos';

  @override
  String get noExpenseHistory => 'Walang kasaysayan ng gastos.';

  @override
  String get editDeleteExpense => 'I-edit/Tanggalin ang Gastos';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Ano ang gusto mong gawin sa gastos na \"$expenseName\"?';
  }

  @override
  String get edit => 'I-edit';

  @override
  String get delete => 'Tanggalin';

  @override
  String get allExpenses => 'Lahat ng Gastos';

  @override
  String get allCategories => 'Lahat ng Kategorya';

  @override
  String get unknown => 'Hindi Alam';

  @override
  String get ascending => 'Pataas';

  @override
  String get descending => 'Pababa';

  @override
  String get noExpenseData => 'Walang data ng gastos.';

  @override
  String get changeFilterPrompt =>
      'Subukang baguhin ang filter o\nmagdagdag ng bagong gastos.';

  @override
  String get allFieldsRequired => 'Pakilagay nang tama ang lahat ng field.';

  @override
  String get addNewCategory => 'Magdagdag ng Bagong Kategorya';

  @override
  String get cancel => 'Kanselahin';

  @override
  String get add => 'Idagdag';

  @override
  String get deleteCategory => 'Tanggalin ang Kategorya';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Sigurado ka bang gusto mong tanggalin ang kategoryang \'$categoryName\'?';
  }

  @override
  String get pleaseWait => 'Pakihintay...';

  @override
  String get noDataExists => 'Walang data.';

  @override
  String get reset => 'I-reset';

  @override
  String get selectDate => 'Pumili ng Petsa';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Kumpirmahin';

  @override
  String get budgetSetting => 'Pag-set ng Badyet';

  @override
  String get save => 'I-save';

  @override
  String get resetInformation => 'I-reset ang Impormasyon';

  @override
  String get notificationPermissionRequired =>
      'Kailangan ng Pahintulot sa Notification';

  @override
  String get notificationPermissionDescription =>
      'Para magamit ang notifications, paki-allow ang permission sa settings.';

  @override
  String get goToSettings => 'Pumunta sa Settings';

  @override
  String get monthlyDiscretionarySpending => 'Flexible';

  @override
  String get monthlyEssentialSpending => 'Mahalaga';

  @override
  String get success => 'Tagumpay';

  @override
  String get failure => 'Bigay';

  @override
  String get consecutiveSuccess => 'Sunod-sunod';

  @override
  String daysCount(Object count) {
    return '$count araw';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Walang laman ang pangalan.';

  @override
  String get invalidAmount => 'Hindi wasto ang halaga o mababa sa 0.';

  @override
  String get categoryNotSelected => 'Hindi napili ang kategorya.';

  @override
  String formValidationError(Object error) {
    return 'Error sa form validation: $error';
  }

  @override
  String get registerExpense => 'Magrehistro ng Gastos';

  @override
  String get register => 'Magrehistro';

  @override
  String get date => 'Petsa';

  @override
  String get expenseName => 'Pangalan ng Gastos';

  @override
  String get enterExpenseName => 'Ilagay ang pangalan ng gastos';

  @override
  String get amount => 'Halaga';

  @override
  String get enterExpenseAmount => 'Ilagay ang halaga ng gastos';

  @override
  String get expenseType => 'Uri ng Gastos';

  @override
  String get essentialExpense => 'Mahalaga';

  @override
  String get discretionaryExpense => 'Flexible';

  @override
  String get categoryName => 'Pangalan ng Kategorya';

  @override
  String get sunday => 'Lin';

  @override
  String get monday => 'Lun';

  @override
  String get tuesday => 'Mar';

  @override
  String get wednesday => 'Miy';

  @override
  String get thursday => 'Huw';

  @override
  String get friday => 'Biy';

  @override
  String get saturday => 'Sab';

  @override
  String errorWithMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get apply => 'Ilapat';

  @override
  String get dataManagement => 'Pamamahala ng Data';

  @override
  String get resetDataConfirmation =>
      'Sigurado ka bang i-reset ang lahat ng data? Hindi na ito maibabalik.';

  @override
  String get notificationSetting => 'Setting ng Notification';

  @override
  String get category => 'Kategorya';

  @override
  String get selectExpenseTypeFirst => 'Pumili muna ng uri ng gastos.';

  @override
  String get errorLoadingCategories => 'Error sa pag-load ng mga kategorya.';

  @override
  String get queryMonth => 'Buwan ng Query';

  @override
  String get remainingAmount => 'Natitirang Halaga';

  @override
  String get todayExpenseMessageZero => 'I-log ang iyong mga gastos ngayon 😊';

  @override
  String get todayExpenseMessageGood => 'Mahusay! Malaki pa ang badyet mo 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Halos kalahati na ang nagamit mo!\nMaging mas maingat ngayon 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Malapit nang maubos ang badyet mo! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Lumagpas ka na sa badyet!\nAyusin ang iyong paggastos ❗';

  @override
  String get information => 'Impormasyon';

  @override
  String get writeReview => 'Sumulat ng Review';

  @override
  String get appVersion => 'Bersyon ng App';

  @override
  String get privacyPolicy => 'Patakaran sa Privacy';

  @override
  String get basicSettings => 'Mga Pangunahing Setting';

  @override
  String get titleAndClose => 'Pamagat at Isara';

  @override
  String get filterSettings => 'Mga Setting ng Filter';

  @override
  String get sort => 'Pagbukud-bukurin';

  @override
  String get latest => 'Pinakabago';

  @override
  String get oldest => 'Pinakaluma';

  @override
  String get statistics => 'Statistics';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get top3ExpensesThisMonth => 'Top 3 Expenses This Month';

  @override
  String get home => 'Home';

  @override
  String get daily => 'Araw-araw';

  @override
  String get monthly => 'Buwanan';

  @override
  String get calendar => 'Kalendaryo';

  @override
  String get stats => 'Stats';

  @override
  String get expense => 'Gastos';

  @override
  String get settings => 'Mga Setting';

  @override
  String get notificationTitleDaily => 'Arawang Paalala sa Gastos';

  @override
  String get notificationBodyMorning =>
      'Magandang umaga ☀️ I-log na ang unang gastos mo. Malaking tulong ang maliliit na gawi!';

  @override
  String get notificationBodyAfternoon =>
      'Nag-enjoy ka ba sa lunch? 🍱 I-update na ang iyong mga gastos.';

  @override
  String get notificationBodyNight =>
      'Patapos na ang araw 🌙 Ayusin na ang iyong mga gastos.';

  @override
  String get resetComplete => 'Salamat sa paggamit ng MoneyFit.';

  @override
  String get upgraderTitle => 'May Update na Available';

  @override
  String get upgraderBody =>
      'May bagong bersyon ng app na available. Paki-update para sa mas magandang karanasan.';

  @override
  String get upgraderPrompt => 'Gusto mo bang mag-update ngayon?';

  @override
  String get upgraderButtonLater => 'Mamaya na';

  @override
  String get upgraderButtonUpdate => 'I-update Ngayon';

  @override
  String get upgraderButtonIgnore => 'Huwag pansinin';

  @override
  String get updateRequiredTitle => 'Kailangang Mag-update';

  @override
  String get updateRequiredBody =>
      'Para sa pinakamainam na karanasan, mag-update sa pinakabagong bersyon.';

  @override
  String get updateAvailableBody =>
      'May bagong bersyon. Subukan ang pinakabagong features at improvements.';

  @override
  String get updateChangelogTitle => 'Ano ang Bago';

  @override
  String get updateButton => 'I-update';

  @override
  String get updateDetails => 'Detalye';

  @override
  String get updateSheetTitle => 'Impormasyon sa Update';

  @override
  String get updateButtonGo => 'Pumunta sa Update';

  @override
  String get review_modal_binary_title => 'Kontento ka ba sa app sa ngayon?';

  @override
  String get review_modal_button_good => 'Maganda';

  @override
  String get review_modal_button_bad => 'Hindi masyado';

  @override
  String get review_positive_title =>
      'Maaari mo bang sabihin kung ano ang nagustuhan mo?';

  @override
  String get review_positive_button_yes => 'Sige';

  @override
  String get review_button_later => 'Mamaya na';

  @override
  String get review_button_never => 'Huwag nang ipakita';

  @override
  String get review_negative_title =>
      'Pakisabi kung alin ang hindi maganda sa karanasan mo.';

  @override
  String get review_negative_hint => 'Isulat ang hindi maginhawa.';

  @override
  String get review_negative_button_send => 'Ipadala';

  @override
  String get review_thanks_message =>
      'Salamat sa iyong feedback. Pagsusumikapan naming pagandahin pa.';

  @override
  String get monthlyExpenseMessageZero =>
      'Wala pang discretionary spending ngayong buwan!';

  @override
  String get monthlyExpenseMessageGood =>
      'Mahusay ang pamamahala ng iyong badyet ngayong buwan!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Ginamit mo na ang halos kalahati ng iyong badyet ngayong buwan.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Halos maubos na ang iyong badyet para sa buwang ito.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Nalagpasan mo na ang iyong badyet para sa buwang ito.';

  @override
  String get contactUs => 'Makipag-ugnayan sa amin';

  @override
  String get inquiryType => 'Uri ng Pagtatanong';

  @override
  String get inquiryTypeBugReport => 'Ulat ng Bug';

  @override
  String get inquiryTypeFeatureSuggestion => 'Mungkahi ng Tampok';

  @override
  String get inquiryTypeGeneralInquiry => 'Pangkalahatang Pagtatanong';

  @override
  String get inquiryTypeOther => 'Iba pa';

  @override
  String get replyEmail => 'Email para sa tugon';

  @override
  String get inquiryDetails => 'Mga Detalye ng Pagtatanong';

  @override
  String get submit => 'Ipasa';

  @override
  String get inquirySuccess => 'Matagumpay na naisumite ang iyong pagtatanong.';

  @override
  String get inquiryFailure => 'Nabigong isumite ang iyong pagtatanong.';

  @override
  String get invalidEmail => 'Mangyaring maglagay ng wastong email address.';

  @override
  String get fieldRequired => 'Kinakailangan ang field na ito.';
}
