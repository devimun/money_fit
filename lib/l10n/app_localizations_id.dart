// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Tidak Perlu Lagi Spreadsheet\nyang Rumit';

  @override
  String get onboardingDescription1 =>
      'Kelola pengeluaran harian Anda dengan mudah dan\nbangun kebiasaan belanja yang sehat.';

  @override
  String get onboardingTitle2 => 'Anggaran Harian dalam Sekejap';

  @override
  String get onboardingDescription2 =>
      'Lacak sisa anggaran Anda untuk hari ini\ndan mulailah berbelanja dengan bijak.';

  @override
  String get onboardingTitle3 => 'Ubah Prestasi menjadi Kebiasaan Abadi';

  @override
  String get onboardingDescription3 =>
      'Ubah tantangan harian menjadi prestasi\ndan nikmati pengelolaan uang Anda.';

  @override
  String get next => 'Berikutnya';

  @override
  String get dailyBudgetSetupTitle => 'Atur Anggaran Anda';

  @override
  String get budgetSetupDescription =>
      'Atur anggaran belanja Anda.\nIni adalah jumlah bebas yang bisa Anda gunakan,\ndi luar biaya tetap (tagihan, medis, dll).';

  @override
  String get dailyBudgetLabel => 'Anggaran Harian (IDR)';

  @override
  String get monthlyBudgetLabel => 'Anggaran Bulanan (IDR)';

  @override
  String get enterBudgetPrompt => 'Silakan masukkan anggaran Anda.';

  @override
  String get enterValidNumberPrompt => 'Silakan masukkan nomor yang valid.';

  @override
  String get budgetGreaterThanZeroPrompt =>
      'Anggaran harus lebih besar dari 0.';

  @override
  String get start => 'Mulai';

  @override
  String errorOccurred(Object error) {
    return 'Terjadi kesalahan: $error';
  }

  @override
  String get dateFormat => 'd MMMM yyyy, EEEE';

  @override
  String get dailyDiscretionarySpending => 'Pengeluaran Diskresioner Harian: ';

  @override
  String get monthlyDiscretionarySpending2 =>
      'Pengeluaran Diskresioner Bulanan: ';

  @override
  String get dailyBudget => 'Anggaran Diskresioner Harian: ';

  @override
  String get monthlyBudget => 'Anggaran Diskresioner Bulanan: ';

  @override
  String get monthlyAvgDiscSpending => 'Disk/Hari (Bulan)';

  @override
  String get consecutiveDays => 'Rangkaian Keberhasilan';

  @override
  String days(Object count) {
    return '$count hari';
  }

  @override
  String get currency => 'Rp';

  @override
  String get viewTodaySpending => 'Lihat\nPengeluaran Hari Ini';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pengeluaran',
      one: '1 pengeluaran',
      zero: 'Belum ada pengeluaran',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Tambah\nPengeluaran Hari Ini';

  @override
  String get addNewExpensePrompt => 'Tambah pengeluaran baru';

  @override
  String get notificationDialogTitle =>
      'Kami bantu Anda mencatat\npengeluaran harian';

  @override
  String get notificationDialogDescription =>
      'Mencatat pengeluaran itu mudah, tapi sering lupa.\nKami akan kirim pengingat harian. Anda mau?';

  @override
  String get notificationDialogDeny => 'Tidak, terima kasih';

  @override
  String get notificationDialogConfirm => 'Ya, tentu';

  @override
  String get category_food => 'Makanan';

  @override
  String get category_traffic => 'Transportasi';

  @override
  String get category_insurance => 'Asuransi';

  @override
  String get category_necessities => 'Kebutuhan Pokok';

  @override
  String get category_communication => 'Komunikasi';

  @override
  String get category_housing => 'Perumahan/Utilitas';

  @override
  String get category_medical => 'Medis';

  @override
  String get category_finance => 'Keuangan';

  @override
  String get categoryEatingOut => 'Makan di Luar';

  @override
  String get category_cafe => 'Kafe/Camilan';

  @override
  String get category_shopping => 'Belanja';

  @override
  String get category_hobby => 'Hobi/Hiburan';

  @override
  String get category_travel => 'Perjalanan/Relaksasi';

  @override
  String get category_subscribe => 'Langganan';

  @override
  String get category_beauty => 'Kecantikan';

  @override
  String get expenseType_essential => 'Penting';

  @override
  String get expenseType_discretionary => 'Diskresioner';

  @override
  String get dailyExpenseHistory => 'Riwayat Pengeluaran Harian';

  @override
  String get noExpenseHistory =>
      'Tidak ada riwayat pengeluaran yang ditemukan.';

  @override
  String get editDeleteExpense => 'Ubah/Hapus Pengeluaran';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Apa yang ingin Anda lakukan dengan pengeluaran \"$expenseName\"';
  }

  @override
  String get edit => 'Ubah';

  @override
  String get delete => 'Hapus';

  @override
  String get allExpenses => 'Semua Pengeluaran';

  @override
  String get allCategories => 'Semua Kategori';

  @override
  String get unknown => 'Tidak Dikenal';

  @override
  String get ascending => 'Naik';

  @override
  String get descending => 'Turun';

  @override
  String get noExpenseData => 'Tidak ada data pengeluaran';

  @override
  String get changeFilterPrompt =>
      'Coba ubah kondisi filter atau\ntambahkan pengeluaran baru';

  @override
  String get allFieldsRequired => 'Silakan isi semua kolom dengan benar.';

  @override
  String get addNewCategory => 'Tambah Kategori Baru';

  @override
  String get cancel => 'Batal';

  @override
  String get add => 'Tambah';

  @override
  String get deleteCategory => 'Hapus Kategori';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Apakah Anda yakin ingin menghapus kategori \'$categoryName\'';
  }

  @override
  String get pleaseWait => 'Mohon tunggu...';

  @override
  String get noDataExists => 'Tidak ada data.';

  @override
  String get reset => 'Atur Ulang';

  @override
  String get selectDate => 'Pilih Tanggal';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get budgetSetting => 'Pengaturan Anggaran';

  @override
  String get save => 'Simpan';

  @override
  String get resetInformation => 'Atur Ulang Informasi';

  @override
  String get notificationPermissionRequired => 'Izin Notifikasi Diperlukan';

  @override
  String get notificationPermissionDescription =>
      'Izinkan notifikasi di Pengaturan\nuntuk memakai fitur pengingat.';

  @override
  String get goToSettings => 'Buka Pengaturan';

  @override
  String get monthlyDiscretionarySpending => 'Diskresioner';

  @override
  String get monthlyEssentialSpending => 'Penting';

  @override
  String get success => 'Berhasil';

  @override
  String get failure => 'Gagal';

  @override
  String get consecutiveSuccess => 'Beruntun';

  @override
  String daysCount(Object count) {
    return '$count hari';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Nama kosong.';

  @override
  String get invalidAmount =>
      'Jumlah tidak valid atau kurang dari atau sama dengan 0.';

  @override
  String get categoryNotSelected => 'Kategori belum dipilih.';

  @override
  String formValidationError(Object error) {
    return 'Kesalahan validasi formulir: $error';
  }

  @override
  String get registerExpense => 'Daftar Pengeluaran';

  @override
  String get register => 'Daftar';

  @override
  String get date => 'Tanggal';

  @override
  String get expenseName => 'Nama Pengeluaran';

  @override
  String get enterExpenseName => 'Silakan masukkan nama pengeluaran';

  @override
  String get amount => 'Jumlah';

  @override
  String get enterExpenseAmount => 'Silakan masukkan jumlah pengeluaran';

  @override
  String get expenseType => 'Jenis Pengeluaran';

  @override
  String get essentialExpense => 'Penting';

  @override
  String get discretionaryExpense => 'Diskresioner';

  @override
  String get categoryName => 'Nama Kategori';

  @override
  String get sunday => 'Min';

  @override
  String get monday => 'Sen';

  @override
  String get tuesday => 'Sel';

  @override
  String get wednesday => 'Rab';

  @override
  String get thursday => 'Kam';

  @override
  String get friday => 'Jum';

  @override
  String get saturday => 'Sab';

  @override
  String errorWithMessage(Object error) {
    return 'Kesalahan: $error';
  }

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get apply => 'Terapkan';

  @override
  String get dataManagement => 'Manajemen Data';

  @override
  String get resetDataConfirmation =>
      'Anda yakin ingin reset semua data?\nTindakan ini tidak bisa dibatalkan.';

  @override
  String get notificationSetting => 'Pengaturan Notifikasi';

  @override
  String get category => 'Kategori';

  @override
  String get selectExpenseTypeFirst =>
      'Silakan pilih jenis pengeluaran terlebih dahulu';

  @override
  String get errorLoadingCategories => 'Gagal memuat kategori';

  @override
  String get queryMonth => 'Kueri Bulan';

  @override
  String get remainingAmount => 'Jumlah Tersisa';

  @override
  String get todayExpenseMessageZero =>
      'Silakan catat pengeluaran Anda hari ini 😊';

  @override
  String get todayExpenseMessageGood =>
      'Bagus! Anggaran Anda masih banyak tersisa 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Anda sudah menggunakan hampir setengahnya!\nAyo lebih berhati-hati sekarang 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Anda hampir melebihi anggaran hari ini! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Anda telah melebihi anggaran hari ini!\nAyo sesuaikan pengeluaran Anda ❗';

  @override
  String get information => 'Informasi';

  @override
  String get writeReview => 'Tulis Ulasan';

  @override
  String get appVersion => 'Versi Aplikasi';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get basicSettings => 'Pengaturan Dasar';

  @override
  String get titleAndClose => 'Judul & Tutup';

  @override
  String get filterSettings => 'Pengaturan Filter';

  @override
  String get sort => 'Urutkan';

  @override
  String get latest => 'Terbaru';

  @override
  String get oldest => 'Terlama';

  @override
  String get statistics => 'Statistics';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get top3ExpensesThisMonth => 'Top 3 Expenses This Month';

  @override
  String get home => 'Beranda';

  @override
  String get daily => 'Harian';

  @override
  String get monthly => 'Bulanan';

  @override
  String get calendar => 'Kalender';

  @override
  String get stats => 'Stat';

  @override
  String get expense => 'Pengeluaran';

  @override
  String get settings => 'Pengaturan';

  @override
  String get notificationTitleDaily => 'Pengingat Pengeluaran Harian';

  @override
  String get notificationBodyMorning =>
      'Selamat pagi ☀️\nCatat pengeluaran pertamamu hari ini!';

  @override
  String get notificationBodyAfternoon =>
      'Sudah makan siang? 🍱\nYuk, perbarui catatan pengeluaranmu.';

  @override
  String get notificationBodyNight =>
      'Hari hampir berakhir 🌙\nTutup harimu dengan merapikan pengeluaran.';

  @override
  String get resetComplete => 'Terima kasih telah menggunakan MoneyFit.';

  @override
  String get upgraderTitle => 'Pembaruan Tersedia';

  @override
  String get upgraderBody =>
      'Versi baru telah tersedia.\nPerbarui untuk pengalaman lebih baik.';

  @override
  String get upgraderPrompt => 'Apakah Anda ingin memperbarui sekarang?';

  @override
  String get upgraderButtonLater => 'Nanti';

  @override
  String get upgraderButtonUpdate => 'Perbarui Sekarang';

  @override
  String get upgraderButtonIgnore => 'Abaikan';

  @override
  String get updateRequiredTitle => 'Pembaruan Diperlukan';

  @override
  String get updateRequiredBody =>
      'Harap perbarui ke versi terbaru untuk pengalaman terbaik.';

  @override
  String get updateAvailableBody =>
      'Versi baru tersedia. Nikmati fitur dan perbaikan terbaru.';

  @override
  String get updateChangelogTitle => 'Yang Baru';

  @override
  String get updateButton => 'Perbarui';

  @override
  String get updateDetails => 'Detail';

  @override
  String get updateSheetTitle => 'Info Pembaruan';

  @override
  String get updateButtonGo => 'Pergi ke Pembaruan';

  @override
  String get review_modal_binary_title =>
      'Apakah Anda puas dengan aplikasi sejauh ini?';

  @override
  String get review_modal_button_good => 'Bagus';

  @override
  String get review_modal_button_bad => 'Kurang puas';

  @override
  String get review_positive_title => 'Bisakah beri tahu apa yang Anda suka?';

  @override
  String get review_positive_button_yes => 'Baik';

  @override
  String get review_button_later => 'Nanti';

  @override
  String get review_button_never => 'Jangan tampilkan lagi';

  @override
  String get review_negative_title => 'Ceritakan bagian yang kurang memuaskan.';

  @override
  String get review_negative_hint => 'Tulis hal yang merepotkan.';

  @override
  String get review_negative_button_send => 'Kirim';

  @override
  String get review_thanks_message =>
      'Terima kasih atas masukan Anda. Kami akan memperbaikinya.';

  @override
  String get monthlyExpenseMessageZero =>
      'Belum ada pengeluaran diskresioner bulan ini!';

  @override
  String get monthlyExpenseMessageGood =>
      'Anggaran Anda terkelola dengan baik bulan ini!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Anda telah menggunakan sekitar setengah dari anggaran Anda bulan ini.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Anggaran Anda hampir habis untuk bulan ini.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Anda telah melebihi anggaran Anda untuk bulan ini.';

  @override
  String get contactUs => 'Hubungi Kami';

  @override
  String get inquiryType => 'Jenis Pertanyaan';

  @override
  String get inquiryTypeBugReport => 'Laporan Bug';

  @override
  String get inquiryTypeFeatureSuggestion => 'Saran Fitur';

  @override
  String get inquiryTypeGeneralInquiry => 'Pertanyaan Umum';

  @override
  String get inquiryTypeOther => 'Lainnya';

  @override
  String get replyEmail => 'Email untuk balasan';

  @override
  String get inquiryDetails => 'Detail Pertanyaan';

  @override
  String get submit => 'Kirim';

  @override
  String get inquirySuccess => 'Pertanyaan Anda telah berhasil dikirim.';

  @override
  String get inquiryFailure => 'Gagal mengirimkan pertanyaan Anda.';

  @override
  String get invalidEmail => 'Silakan masukkan alamat email yang valid.';

  @override
  String get fieldRequired => 'Bagian ini wajib diisi.';
}
