// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Urus Wang Tanpa Stres';

  @override
  String get onboardingDescription1 =>
      'Urus belanja harian dengan mudah dan\nbina tabiat kewangan yang sihat.';

  @override
  String get onboardingTitle2 => 'Bajet Harian Sepintas Lalu';

  @override
  String get onboardingDescription2 =>
      'Jejaki baki bajet harian anda dan\nmula berbelanja dengan lebih bijak.';

  @override
  String get onboardingTitle3 => 'Bina Tabiat Kewangan Hebat';

  @override
  String get onboardingDescription3 =>
      'Ubah cabaran harian menjadi pencapaian dan\nnikmati pengurusan wang anda.';

  @override
  String get next => 'Seterusnya';

  @override
  String get dailyBudgetSetupTitle => 'Tetapkan Bajet Anda';

  @override
  String get budgetSetupDescription =>
      'Tetapkan bajet belanja fleksibel anda.\nBelanja fleksibel ialah wang yang boleh anda guna secara bebas, tidak termasuk kos tetap seperti bil, perubatan, perumahan, dan insurans.';

  @override
  String get dailyBudgetLabel => 'Bajet Harian(MYR)';

  @override
  String get monthlyBudgetLabel => 'Bajet Bulanan (MYR)';

  @override
  String get enterBudgetPrompt => 'Masukkan bajet anda.';

  @override
  String get enterValidNumberPrompt => 'Sila masukkan nombor yang sah.';

  @override
  String get budgetGreaterThanZeroPrompt => 'Bajet mesti lebih daripada 0.';

  @override
  String get start => 'Mulakan';

  @override
  String errorOccurred(Object error) {
    return 'Ralat berlaku: $error';
  }

  @override
  String get dateFormat => 'd MMMM yyyy, EEEE';

  @override
  String get dailyDiscretionarySpending =>
      'Perbelanjaan Diskresionari Harian: ';

  @override
  String get monthlyDiscretionarySpending2 =>
      'Perbelanjaan Diskresionari Bulanan: ';

  @override
  String get dailyBudget => 'Belanjawan Diskresionari Harian: ';

  @override
  String get monthlyBudget => 'Belanjawan Diskresionari Bulanan: ';

  @override
  String get monthlyAvgDiscSpending => 'Fleksibel/Hari (Bulanan)';

  @override
  String get consecutiveDays => 'Kejayaan Berturut-turut';

  @override
  String days(Object count) {
    return '$count hari';
  }

  @override
  String get currency => 'RM';

  @override
  String get viewTodaySpending => 'Lihat\nBelanja Hari Ini';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perbelanjaan',
      one: '1 perbelanjaan',
      zero: 'Tiada perbelanjaan',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Tambah\nBelanja Hari Ini';

  @override
  String get addNewExpensePrompt => 'Tambah perbelanjaan baharu';

  @override
  String get notificationDialogTitle => 'Peringatan Catat Belanja';

  @override
  String get notificationDialogDescription =>
      'Mencatat belanja memang mudah, tapi mudah juga terlupa.\nKami akan hantar notifikasi harian untuk bantu anda. Anda ingin terima notifikasi?';

  @override
  String get notificationDialogDeny => 'Tidak, terima kasih';

  @override
  String get notificationDialogConfirm => 'Ya';

  @override
  String get category_food => 'Makanan';

  @override
  String get category_traffic => 'Pengangkutan';

  @override
  String get category_insurance => 'Insurans';

  @override
  String get category_necessities => 'Keperluan Asas';

  @override
  String get category_communication => 'Komunikasi';

  @override
  String get category_housing => 'Perumahan/Utiliti';

  @override
  String get category_medical => 'Perubatan';

  @override
  String get category_finance => 'Kewangan';

  @override
  String get categoryEatingOut => 'Makan Luar';

  @override
  String get category_cafe => 'Kafe/Snek';

  @override
  String get category_shopping => 'Membeli-belah';

  @override
  String get category_hobby => 'Hobi/Riadah';

  @override
  String get category_travel => 'Pelancongan/Santai';

  @override
  String get category_subscribe => 'Langganan';

  @override
  String get category_beauty => 'Kecantikan';

  @override
  String get expenseType_essential => 'Penting';

  @override
  String get expenseType_discretionary => 'Fleksibel';

  @override
  String get dailyExpenseHistory => 'Sejarah Perbelanjaan Harian';

  @override
  String get noExpenseHistory => 'Tiada sejarah perbelanjaan.';

  @override
  String get editDeleteExpense => 'Edit/Padam Perbelanjaan';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Apa yang anda ingin lakukan dengan belanja \"$expenseName\"';
  }

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Padam';

  @override
  String get allExpenses => 'Semua Perbelanjaan';

  @override
  String get allCategories => 'Semua Kategori';

  @override
  String get unknown => 'Tidak Diketahui';

  @override
  String get ascending => 'Menaik';

  @override
  String get descending => 'Menurun';

  @override
  String get noExpenseData => 'Tiada data perbelanjaan.';

  @override
  String get changeFilterPrompt =>
      'Cuba tukar tetapan penapis atau\ntambah belanja baharu.';

  @override
  String get allFieldsRequired => 'Sila isi semua ruangan dengan betul.';

  @override
  String get addNewCategory => 'Tambah Kategori Baharu';

  @override
  String get cancel => 'Batal';

  @override
  String get add => 'Tambah';

  @override
  String get deleteCategory => 'Padam Kategori';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Anda pasti ingin padam kategori \'$categoryName\'?';
  }

  @override
  String get pleaseWait => 'Sila tunggu...';

  @override
  String get noDataExists => 'Tiada data.';

  @override
  String get reset => 'Tetap Semula';

  @override
  String get selectDate => 'Pilih Tarikh';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Sahkan';

  @override
  String get budgetSetting => 'Tetapan Bajet';

  @override
  String get save => 'Simpan';

  @override
  String get resetInformation => 'Tetapan Semula Maklumat';

  @override
  String get notificationPermissionRequired =>
      'Kebenaran Notifikasi Diperlukan';

  @override
  String get notificationPermissionDescription =>
      'Untuk guna ciri notifikasi, sila benarkan\nkebenaran notifikasi dalam tetapan.';

  @override
  String get goToSettings => 'Pergi ke Tetapan';

  @override
  String get monthlyDiscretionarySpending => 'Fleksibel';

  @override
  String get monthlyEssentialSpending => 'Penting';

  @override
  String get success => 'Berjaya';

  @override
  String get failure => 'Gagal';

  @override
  String get consecutiveSuccess => 'Berturut-turut';

  @override
  String daysCount(Object count) {
    return '$count hari';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Nama tidak diisi.';

  @override
  String get invalidAmount => 'Jumlah tidak sah atau kurang daripada 0.';

  @override
  String get categoryNotSelected => 'Kategori tidak dipilih.';

  @override
  String formValidationError(Object error) {
    return 'Ralat pengesahan borang: $error';
  }

  @override
  String get registerExpense => 'Daftar Perbelanjaan';

  @override
  String get register => 'Daftar';

  @override
  String get date => 'Tarikh';

  @override
  String get expenseName => 'Nama Perbelanjaan';

  @override
  String get enterExpenseName => 'Masukkan nama perbelanjaan';

  @override
  String get amount => 'Jumlah';

  @override
  String get enterExpenseAmount => 'Masukkan jumlah perbelanjaan';

  @override
  String get expenseType => 'Jenis Perbelanjaan';

  @override
  String get essentialExpense => 'Penting';

  @override
  String get discretionaryExpense => 'Fleksibel';

  @override
  String get categoryName => 'Nama Kategori';

  @override
  String get sunday => 'Aha';

  @override
  String get monday => 'Isn';

  @override
  String get tuesday => 'Sel';

  @override
  String get wednesday => 'Rab';

  @override
  String get thursday => 'Kha';

  @override
  String get friday => 'Jum';

  @override
  String get saturday => 'Sab';

  @override
  String errorWithMessage(Object error) {
    return 'Ralat: $error';
  }

  @override
  String get darkMode => 'Mod Gelap';

  @override
  String get apply => 'Guna';

  @override
  String get dataManagement => 'Pengurusan Data';

  @override
  String get resetDataConfirmation =>
      'Anda pasti ingin tetap semula semua data? Tindakan ini tidak boleh dibatalkan.';

  @override
  String get notificationSetting => 'Tetapan Notifikasi';

  @override
  String get category => 'Kategori';

  @override
  String get selectExpenseTypeFirst => 'Sila pilih jenis perbelanjaan dahulu.';

  @override
  String get errorLoadingCategories => 'Ralat memuatkan kategori.';

  @override
  String get queryMonth => 'Pilih Bulan';

  @override
  String get remainingAmount => 'Jumlah Baki';

  @override
  String get todayExpenseMessageZero => 'Sila catat belanja anda hari ini 😊';

  @override
  String get todayExpenseMessageGood => 'Hebat! Bajet anda masih banyak 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Anda dah guna hampir separuh!\nJom lebih berhati-hati 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Bajet harian anda hampir habis! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Anda sudah melebihi bajet!\nJom kawal semula perbelanjaan anda ❗';

  @override
  String get information => 'Maklumat';

  @override
  String get writeReview => 'Beri Ulasan';

  @override
  String get appVersion => 'Versi Aplikasi';

  @override
  String get privacyPolicy => 'Dasar Privasi';

  @override
  String get basicSettings => 'Tetapan Asas';

  @override
  String get titleAndClose => 'Tajuk & Tutup';

  @override
  String get filterSettings => 'Tetapan Penapis';

  @override
  String get sort => 'Isih';

  @override
  String get latest => 'Terkini';

  @override
  String get oldest => 'Terlama';

  @override
  String get statistics => 'Statistics';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get top3ExpensesThisMonth => 'Top 3 Expenses This Month';

  @override
  String get home => 'Utama';

  @override
  String get daily => 'Harian';

  @override
  String get monthly => 'Bulanan';

  @override
  String get calendar => 'Kalendar';

  @override
  String get stats => 'Stat';

  @override
  String get expense => 'Perbelanjaan';

  @override
  String get settings => 'Tetapan';

  @override
  String get notificationTitleDaily => 'Peringatan Belanja Harian';

  @override
  String get notificationBodyMorning =>
      'Selamat pagi ☀️ Jom catat belanja pertama anda. Tabiat kecil membawa perubahan besar!';

  @override
  String get notificationBodyAfternoon =>
      'Dah makan tengah hari? 🍱 Jom kemas kini belanja anda.';

  @override
  String get notificationBodyNight =>
      'Hari dah nak berakhir 🌙 Lengkapkan hari anda dengan mengurus belanja.';

  @override
  String get resetComplete => 'Terima kasih kerana menggunakan MoneyFit.';

  @override
  String get upgraderTitle => 'Kemas Kini Tersedia';

  @override
  String get upgraderBody =>
      'Versi baharu apl tersedia. Sila kemas kini untuk pengalaman yang lebih baik.';

  @override
  String get upgraderPrompt => 'Adakah anda mahu mengemas kini sekarang?';

  @override
  String get upgraderButtonLater => 'Nanti';

  @override
  String get upgraderButtonUpdate => 'Kemas kini Sekarang';

  @override
  String get upgraderButtonIgnore => 'Abaikan';

  @override
  String get updateRequiredTitle => 'Kemas Kini Diperlukan';

  @override
  String get updateRequiredBody =>
      'Sila kemas kini ke versi terkini untuk pengalaman terbaik.';

  @override
  String get updateAvailableBody =>
      'Versi baharu tersedia. Nikmati ciri dan penambahbaikan terkini.';

  @override
  String get updateChangelogTitle => 'Apa Yang Baharu';

  @override
  String get updateButton => 'Kemas kini';

  @override
  String get updateDetails => 'Butiran';

  @override
  String get updateSheetTitle => 'Maklumat Kemas Kini';

  @override
  String get updateButtonGo => 'Pergi ke Kemas Kini';

  @override
  String get review_modal_binary_title =>
      'Adakah anda berpuas hati dengan aplikasi setakat ini?';

  @override
  String get review_modal_button_good => 'Baik';

  @override
  String get review_modal_button_bad => 'Kurang baik';

  @override
  String get review_positive_title => 'Boleh kongsi apa yang anda suka?';

  @override
  String get review_positive_button_yes => 'Baik';

  @override
  String get review_button_later => 'Nanti';

  @override
  String get review_button_never => 'Jangan tunjuk lagi';

  @override
  String get review_negative_title =>
      'Beritahu kami apa yang kurang memuaskan.';

  @override
  String get review_negative_hint => 'Tulis perkara yang menyusahkan.';

  @override
  String get review_negative_button_send => 'Hantar';

  @override
  String get review_thanks_message =>
      'Terima kasih atas maklum balas anda. Kami akan perbaiki.';

  @override
  String get monthlyExpenseMessageZero =>
      'Tiada perbelanjaan budi bicara bulan ini lagi!';

  @override
  String get monthlyExpenseMessageGood =>
      'Belanjawan anda diurus dengan baik bulan ini!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Anda telah menggunakan kira-kira separuh daripada belanjawan anda bulan ini.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Belanjawan anda hampir habis untuk bulan ini.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Anda telah melebihi belanjawan anda untuk bulan ini.';

  @override
  String get contactUs => 'Hubungi Kami';

  @override
  String get inquiryType => 'Jenis Pertanyaan';

  @override
  String get inquiryTypeBugReport => 'Laporan Pepijat';

  @override
  String get inquiryTypeFeatureSuggestion => 'Cadangan Ciri';

  @override
  String get inquiryTypeGeneralInquiry => 'Pertanyaan Umum';

  @override
  String get inquiryTypeOther => 'Lain-lain';

  @override
  String get replyEmail => 'E-mel untuk balasan';

  @override
  String get inquiryDetails => 'Butiran Pertanyaan';

  @override
  String get submit => 'Hantar';

  @override
  String get inquirySuccess => 'Pertanyaan anda telah berjaya dihantar.';

  @override
  String get inquiryFailure => 'Gagal menghantar pertanyaan anda.';

  @override
  String get invalidEmail => 'Sila masukkan alamat e-mel yang sah.';

  @override
  String get fieldRequired => 'Ruangan ini diperlukan.';
}
