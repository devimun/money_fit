// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Більше ніяких складних таблиць';

  @override
  String get onboardingDescription1 =>
      'Легко керуйте щоденними витратами та формуйте здорові фінансові звички.';

  @override
  String get onboardingTitle2 => 'Денний бюджет з першого погляду';

  @override
  String get onboardingDescription2 =>
      'Відстежуйте залишок бюджету на сьогодні та починайте витрачати усвідомлено.';

  @override
  String get onboardingTitle3 => 'Перетворіть досягнення на звички';

  @override
  String get onboardingDescription3 =>
      'Перетворюйте щоденні виклики на досягнення та насолоджуйтесь управлінням грошима.';

  @override
  String get next => 'Далі';

  @override
  String get dailyBudgetSetupTitle => 'Встановіть бюджет';

  @override
  String get budgetSetupDescription =>
      'Встановіть бюджет на дискреційні витрати. Дискреційні витрати — це сума, яку ви можете вільно використовувати, за винятком фіксованих витрат, таких як рахунки, медичні витрати, житло та страхування.';

  @override
  String get dailyBudgetLabel => 'Денний бюджет';

  @override
  String get monthlyBudgetLabel => 'Місячний бюджет';

  @override
  String get enterBudgetPrompt => 'Будь ласка, введіть бюджет.';

  @override
  String get enterValidNumberPrompt => 'Будь ласка, введіть дійсне число.';

  @override
  String get budgetGreaterThanZeroPrompt => 'Бюджет має бути більше 0.';

  @override
  String get start => 'Почати';

  @override
  String errorOccurred(Object error) {
    return 'Сталася помилка: $error';
  }

  @override
  String get dateFormat => 'd MMMM yyyy, EEEE';

  @override
  String get dailyDiscretionarySpending => 'Щоденні дискреційні витрати: ';

  @override
  String get monthlyDiscretionarySpending2 => 'Місячні дискреційні витрати: ';

  @override
  String get dailyBudget => 'Денний дискреційний бюджет: ';

  @override
  String get monthlyBudget => 'Місячний дискреційний бюджет: ';

  @override
  String get monthlyAvgDiscSpending => 'Дискр/День (Міс.)';

  @override
  String get consecutiveDays => 'Серія успіхів';

  @override
  String days(Object count) {
    return '$count днів';
  }

  @override
  String get viewTodaySpending => 'Переглянути\nвитрати за сьогодні';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count витрат',
      few: '$count витрати',
      one: '1 витрата',
      zero: 'Ще немає витрат',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Додати\nвитрату за сьогодні';

  @override
  String get addNewExpensePrompt => 'Додайте нову витрату';

  @override
  String get notificationDialogTitle =>
      'Ми допоможемо вам пам\'ятати про записи витрат';

  @override
  String get notificationDialogDescription =>
      'Записувати витрати легко, але також легко забути. Ми надсилатимемо щоденні нагадування. Бажаєте отримувати сповіщення?';

  @override
  String get notificationDialogDeny => 'Ні, дякую';

  @override
  String get notificationDialogConfirm => 'Так, будь ласка';

  @override
  String get category_food => 'Їжа';

  @override
  String get category_traffic => 'Транспорт';

  @override
  String get category_insurance => 'Страхування';

  @override
  String get category_necessities => 'Предмети першої необхідності';

  @override
  String get category_communication => 'Зв\'язок';

  @override
  String get category_housing => 'Житло/Комунальні';

  @override
  String get category_medical => 'Медичні';

  @override
  String get category_finance => 'Фінанси';

  @override
  String get categoryEatingOut => 'Їжа поза домом';

  @override
  String get category_cafe => 'Кафе/Перекуси';

  @override
  String get category_shopping => 'Покупки';

  @override
  String get category_hobby => 'Хобі/Дозвілля';

  @override
  String get category_travel => 'Подорожі/Відпочинок';

  @override
  String get category_subscribe => 'Підписки';

  @override
  String get category_beauty => 'Краса';

  @override
  String get expenseType_essential => 'Необхідні';

  @override
  String get expenseType_discretionary => 'Дискреційні';

  @override
  String get dailyExpenseHistory => 'Історія щоденних витрат';

  @override
  String get noExpenseHistory => 'Історію витрат не знайдено.';

  @override
  String get editDeleteExpense => 'Редагувати/Видалити витрату';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Що ви хочете зробити з витратою \"$expenseName\"?';
  }

  @override
  String get edit => 'Редагувати';

  @override
  String get delete => 'Видалити';

  @override
  String get allExpenses => 'Усі витрати';

  @override
  String get allCategories => 'Усі категорії';

  @override
  String get unknown => 'Невідомо';

  @override
  String get ascending => 'За зростанням';

  @override
  String get descending => 'За спаданням';

  @override
  String get noExpenseData => 'Немає даних про витрати';

  @override
  String get changeFilterPrompt =>
      'Спробуйте змінити фільтри або додайте нову витрату';

  @override
  String get allFieldsRequired => 'Будь ласка, заповніть усі поля правильно.';

  @override
  String get addNewCategory => 'Додати нову категорію';

  @override
  String get cancel => 'Скасувати';

  @override
  String get add => 'Додати';

  @override
  String get deleteCategory => 'Видалити категорію';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Ви впевнені, що хочете видалити категорію \'$categoryName\'?';
  }

  @override
  String get pleaseWait => 'Будь ласка, зачекайте...';

  @override
  String get noDataExists => 'Немає даних.';

  @override
  String get reset => 'Скинути';

  @override
  String get selectDate => 'Вибрати дату';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Підтвердити';

  @override
  String get budgetSetting => 'Налаштування бюджету';

  @override
  String get save => 'Зберегти';

  @override
  String get resetInformation => 'Скинути інформацію';

  @override
  String get notificationPermissionRequired => 'Потрібен дозвіл на сповіщення';

  @override
  String get notificationPermissionDescription =>
      'Щоб використовувати сповіщення, дозвольте їх у налаштуваннях.';

  @override
  String get goToSettings => 'Перейти до Налаштувань';

  @override
  String get monthlyDiscretionarySpending => 'Дискреційні';

  @override
  String get monthlyEssentialSpending => 'Необхідні';

  @override
  String get success => 'Успіх';

  @override
  String get failure => 'Невдача';

  @override
  String get consecutiveSuccess => 'Серія';

  @override
  String daysCount(Object count) {
    return '$count днів';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Назва порожня.';

  @override
  String get invalidAmount => 'Сума недійсна або менше або дорівнює 0.';

  @override
  String get categoryNotSelected => 'Категорію не вибрано.';

  @override
  String formValidationError(Object error) {
    return 'Помилка валідації: $error';
  }

  @override
  String get registerExpense => 'Зареєструвати витрату';

  @override
  String get register => 'Зареєструвати';

  @override
  String get date => 'Дата';

  @override
  String get expenseName => 'Назва витрати';

  @override
  String get enterExpenseName => 'Введіть назву витрати';

  @override
  String get amount => 'Сума';

  @override
  String get enterExpenseAmount => 'Введіть суму витрати';

  @override
  String get expenseType => 'Тип витрати';

  @override
  String get essentialExpense => 'Необхідна';

  @override
  String get discretionaryExpense => 'Дискреційна';

  @override
  String get categoryName => 'Назва категорії';

  @override
  String get sunday => 'Нд';

  @override
  String get monday => 'Пн';

  @override
  String get tuesday => 'Вт';

  @override
  String get wednesday => 'Ср';

  @override
  String get thursday => 'Чт';

  @override
  String get friday => 'Пт';

  @override
  String get saturday => 'Сб';

  @override
  String errorWithMessage(Object error) {
    return 'Помилка: $error';
  }

  @override
  String get darkMode => 'Темний режим';

  @override
  String get themeColor => 'Колір теми';

  @override
  String get themeColorDescription => 'Налаштуйте кольорову схему додатку';

  @override
  String get fontSize => 'Розмір шрифту';

  @override
  String get fontSizeDescription =>
      'Налаштуйте розмір тексту для кращої читабельності';

  @override
  String get fontSizeSmall => 'Малий';

  @override
  String get fontSizeMedium => 'Середній';

  @override
  String get fontSizeLarge => 'Великий';

  @override
  String get apply => 'Застосувати';

  @override
  String get dataManagement => 'Управління даними';

  @override
  String get resetDataConfirmation =>
      'Ви впевнені, що хочете скинути всі дані? Цю дію не можна скасувати.';

  @override
  String get notificationSetting => 'Налаштування сповіщень';

  @override
  String get category => 'Категорія';

  @override
  String get selectExpenseTypeFirst => 'Спочатку виберіть тип витрати';

  @override
  String get errorLoadingCategories => 'Помилка завантаження категорій';

  @override
  String get queryMonth => 'Місяць запиту';

  @override
  String get remainingAmount => 'Залишок';

  @override
  String get todayExpenseMessageZero => 'Запишіть свої витрати за сьогодні 😊';

  @override
  String get todayExpenseMessageGood => 'Чудово! У вас ще багато бюджету 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Ви використали майже половину! Будьмо обережнішими 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Ви близькі до перевищення сьогоднішнього бюджету! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Ви перевищили сьогоднішній бюджет! Давайте скоригуємо витрати ❗';

  @override
  String get information => 'Інформація';

  @override
  String get writeReview => 'Написати відгук';

  @override
  String get appVersion => 'Версія додатку';

  @override
  String get privacyPolicy => 'Політика конфіденційності';

  @override
  String get basicSettings => 'Основні налаштування';

  @override
  String get titleAndClose => 'Заголовок і закрити';

  @override
  String get filterSettings => 'Налаштування фільтрів';

  @override
  String get sort => 'Сортувати';

  @override
  String get latest => 'Найновіші';

  @override
  String get oldest => 'Найстаріші';

  @override
  String get statistics => 'Статистика';

  @override
  String get spendingByCategory => 'Витрати за категоріями';

  @override
  String get top3ExpensesThisMonth => 'Топ-3 витрати цього місяця';

  @override
  String get home => 'Головна';

  @override
  String get daily => 'Щоденно';

  @override
  String get monthly => 'Щомісяця';

  @override
  String get calendar => 'Календар';

  @override
  String get stats => 'Статистика';

  @override
  String get expense => 'Витрати';

  @override
  String get settings => 'Налаштування';

  @override
  String get notificationTitleDaily => 'Нагадування про витрати';

  @override
  String get notificationBodyMorning =>
      'Доброго ранку! ☀️ Готові записати першу витрату дня? Маленькі звички роблять велику різницю!';

  @override
  String get notificationBodyAfternoon =>
      'Смачний обід? 🍱 Як щодо швидкого оновлення витрат?';

  @override
  String get notificationBodyNight =>
      'День майже закінчився 🌙 Завершіть його, впорядкувавши витрати.';

  @override
  String get resetComplete => 'Дякуємо за використання MoneyFit.';

  @override
  String get upgraderTitle => 'Доступне оновлення';

  @override
  String get upgraderBody =>
      'Доступна нова версія додатку. Оновіть для кращого досвіду.';

  @override
  String get upgraderPrompt => 'Бажаєте оновити зараз?';

  @override
  String get upgraderButtonLater => 'Пізніше';

  @override
  String get upgraderButtonUpdate => 'Оновити зараз';

  @override
  String get upgraderButtonIgnore => 'Ігнорувати';

  @override
  String get updateRequiredTitle => 'Потрібне оновлення';

  @override
  String get updateRequiredBody =>
      'Оновіть до останньої версії для найкращого досвіду.';

  @override
  String get updateAvailableBody =>
      'Доступна нова версія. Насолоджуйтесь останніми функціями та покращеннями.';

  @override
  String get updateChangelogTitle => 'Що нового';

  @override
  String get updateButton => 'Оновити';

  @override
  String get updateDetails => 'Деталі';

  @override
  String get updateSheetTitle => 'Інформація про оновлення';

  @override
  String get updateButtonGo => 'Перейти до оновлення';

  @override
  String get review_modal_binary_title => 'Чи задоволені ви додатком?';

  @override
  String get review_modal_button_good => 'Мені сподобалось';

  @override
  String get review_modal_button_bad => 'Не дуже';

  @override
  String get review_positive_title =>
      'Чи можете розповісти, що вам сподобалось?';

  @override
  String get review_positive_button_yes => 'Звичайно';

  @override
  String get review_button_later => 'Пізніше';

  @override
  String get review_button_never => 'Більше не показувати';

  @override
  String get review_negative_title => 'Розкажіть, що вам не підійшло.';

  @override
  String get review_negative_hint => 'Розкажіть, що було незручно.';

  @override
  String get review_negative_button_send => 'Надіслати';

  @override
  String get review_thanks_message =>
      'Дякуємо за відгук. Ми працюватимемо над покращенням.';

  @override
  String get monthlyExpenseMessageZero =>
      'Ще немає дискреційних витрат цього місяця!';

  @override
  String get monthlyExpenseMessageGood =>
      'Ваш бюджет добре керується цього місяця!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Ви використали приблизно половину бюджету цього місяця.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Ваш бюджет майже вичерпано цього місяця.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Ви перевищили бюджет цього місяця.';

  @override
  String get contactUs => 'Зв\'яжіться з нами';

  @override
  String get inquiryType => 'Тип запиту';

  @override
  String get inquiryTypeBugReport => 'Повідомлення про помилку';

  @override
  String get inquiryTypeFeatureSuggestion => 'Пропозиція функції';

  @override
  String get inquiryTypeGeneralInquiry => 'Загальний запит';

  @override
  String get inquiryTypeOther => 'Інше';

  @override
  String get replyEmail => 'Email для відповіді';

  @override
  String get optional => 'Необов\'язково';

  @override
  String get inquiryDetails => 'Деталі запиту';

  @override
  String get submit => 'Надіслати';

  @override
  String get inquirySuccess => 'Ваш запит успішно надіслано.';

  @override
  String get inquiryFailure => 'Не вдалося надіслати запит.';

  @override
  String get invalidEmail => 'Введіть дійсну адресу email.';

  @override
  String get fieldRequired => 'Це поле обов\'язкове.';

  @override
  String get selectThemeColor => 'Вибрати колір теми';

  @override
  String get quickSelect => 'Швидкий вибір';

  @override
  String get recentColors => 'Останні кольори';

  @override
  String get customSelect => 'Власний вибір';

  @override
  String get close => 'Закрити';

  @override
  String get languageSetting => 'Мова та валюта';

  @override
  String get selectLanguage => 'Вибрати мову';
}
