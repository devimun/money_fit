// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'Край на сложните таблици';

  @override
  String get onboardingDescription1 =>
      'Лесно управлявайте ежедневните си разходи и изградете здравословни навици за харчене.';

  @override
  String get onboardingTitle2 => 'Дневен бюджет с един поглед';

  @override
  String get onboardingDescription2 =>
      'Следете оставащия бюджет за днес и започнете да харчите съзнателно.';

  @override
  String get onboardingTitle3 => 'Превърнете постиженията в трайни навици';

  @override
  String get onboardingDescription3 =>
      'Превърнете ежедневните предизвикателства в постижения и се наслаждавайте на управлението на парите.';

  @override
  String get next => 'Напред';

  @override
  String get dailyBudgetSetupTitle => 'Задайте бюджет';

  @override
  String get budgetSetupDescription =>
      'Задайте бюджет за дискреционни разходи. Дискреционните разходи са сумата, която можете да използвате свободно, без фиксираните разходи като сметки, медицински разходи, жилище и застраховки.';

  @override
  String get dailyBudgetLabel => 'Дневен бюджет';

  @override
  String get monthlyBudgetLabel => 'Месечен бюджет';

  @override
  String get enterBudgetPrompt => 'Моля, въведете бюджета си.';

  @override
  String get enterValidNumberPrompt => 'Моля, въведете валидно число.';

  @override
  String get budgetGreaterThanZeroPrompt =>
      'Бюджетът трябва да е по-голям от 0.';

  @override
  String get start => 'Започни';

  @override
  String errorOccurred(Object error) {
    return 'Възникна грешка: $error';
  }

  @override
  String get dateFormat => 'EEEE, d MMMM yyyy';

  @override
  String get dailyDiscretionarySpending => 'Дневни дискреционни разходи: ';

  @override
  String get monthlyDiscretionarySpending2 => 'Месечни дискреционни разходи: ';

  @override
  String get dailyBudget => 'Дневен дискреционен бюджет: ';

  @override
  String get monthlyBudget => 'Месечен дискреционен бюджет: ';

  @override
  String get monthlyAvgDiscSpending => 'Дискр/Ден (Мес.)';

  @override
  String get consecutiveDays => 'Серия успехи';

  @override
  String days(Object count) {
    return '$count дни';
  }

  @override
  String get viewTodaySpending => 'Виж днешните\nразходи';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count разхода',
      one: '1 разход',
      zero: 'Все още няма разходи',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Добави\nднешен разход';

  @override
  String get addNewExpensePrompt => 'Добавете нов разход';

  @override
  String get notificationDialogTitle =>
      'Ще ви помогнем да помните да записвате разходите';

  @override
  String get notificationDialogDescription =>
      'Записването на разходи е лесно, но също е лесно да се забрави. Ще ви изпращаме ежедневни напомняния. Искате ли да получавате известия?';

  @override
  String get notificationDialogDeny => 'Не, благодаря';

  @override
  String get notificationDialogConfirm => 'Да, моля';

  @override
  String get category_food => 'Храна';

  @override
  String get category_traffic => 'Транспорт';

  @override
  String get category_insurance => 'Застраховка';

  @override
  String get category_necessities => 'Необходимости';

  @override
  String get category_communication => 'Комуникация';

  @override
  String get category_housing => 'Жилище/Комунални';

  @override
  String get category_medical => 'Медицински';

  @override
  String get category_finance => 'Финанси';

  @override
  String get categoryEatingOut => 'Хранене навън';

  @override
  String get category_cafe => 'Кафене/Закуски';

  @override
  String get category_shopping => 'Пазаруване';

  @override
  String get category_hobby => 'Хоби/Свободно време';

  @override
  String get category_travel => 'Пътуване/Почивка';

  @override
  String get category_subscribe => 'Абонаменти';

  @override
  String get category_beauty => 'Красота';

  @override
  String get expenseType_essential => 'Необходими';

  @override
  String get expenseType_discretionary => 'Дискреционни';

  @override
  String get dailyExpenseHistory => 'История на дневните разходи';

  @override
  String get noExpenseHistory => 'Не е намерена история на разходите.';

  @override
  String get editDeleteExpense => 'Редактирай/Изтрий разход';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'Какво искате да направите с разхода \"$expenseName\"?';
  }

  @override
  String get edit => 'Редактирай';

  @override
  String get delete => 'Изтрий';

  @override
  String get allExpenses => 'Всички разходи';

  @override
  String get allCategories => 'Всички категории';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get ascending => 'Възходящо';

  @override
  String get descending => 'Низходящо';

  @override
  String get noExpenseData => 'Няма данни за разходи';

  @override
  String get changeFilterPrompt =>
      'Опитайте да промените филтрите или добавете нов разход';

  @override
  String get allFieldsRequired => 'Моля, попълнете всички полета правилно.';

  @override
  String get addNewCategory => 'Добави нова категория';

  @override
  String get cancel => 'Отказ';

  @override
  String get add => 'Добави';

  @override
  String get deleteCategory => 'Изтрий категория';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Сигурни ли сте, че искате да изтриете категорията \'$categoryName\'?';
  }

  @override
  String get pleaseWait => 'Моля, изчакайте...';

  @override
  String get noDataExists => 'Няма данни.';

  @override
  String get reset => 'Нулиране';

  @override
  String get selectDate => 'Избери дата';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Потвърди';

  @override
  String get budgetSetting => 'Настройка на бюджет';

  @override
  String get save => 'Запази';

  @override
  String get resetInformation => 'Нулиране на информация';

  @override
  String get notificationPermissionRequired =>
      'Необходимо е разрешение за известия';

  @override
  String get notificationPermissionDescription =>
      'За да използвате известия, разрешете ги в настройките.';

  @override
  String get goToSettings => 'Към Настройки';

  @override
  String get monthlyDiscretionarySpending => 'Дискреционни';

  @override
  String get monthlyEssentialSpending => 'Необходими';

  @override
  String get success => 'Успех';

  @override
  String get failure => 'Неуспех';

  @override
  String get consecutiveSuccess => 'Серия';

  @override
  String daysCount(Object count) {
    return '$count дни';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Името е празно.';

  @override
  String get invalidAmount => 'Сумата е невалидна или по-малка или равна на 0.';

  @override
  String get categoryNotSelected => 'Категорията не е избрана.';

  @override
  String formValidationError(Object error) {
    return 'Грешка при валидация: $error';
  }

  @override
  String get registerExpense => 'Регистрирай разход';

  @override
  String get register => 'Регистрирай';

  @override
  String get date => 'Дата';

  @override
  String get expenseName => 'Име на разход';

  @override
  String get enterExpenseName => 'Въведете име на разхода';

  @override
  String get amount => 'Сума';

  @override
  String get enterExpenseAmount => 'Въведете сума на разхода';

  @override
  String get expenseType => 'Тип разход';

  @override
  String get essentialExpense => 'Необходим';

  @override
  String get discretionaryExpense => 'Дискреционен';

  @override
  String get categoryName => 'Име на категория';

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
    return 'Грешка: $error';
  }

  @override
  String get darkMode => 'Тъмен режим';

  @override
  String get themeColor => 'Цвят на темата';

  @override
  String get themeColorDescription =>
      'Персонализирайте цветовата схема на приложението';

  @override
  String get fontSize => 'Размер на шрифта';

  @override
  String get fontSizeDescription =>
      'Регулирайте размера на текста за по-добра четимост';

  @override
  String get fontSizeSmall => 'Малък';

  @override
  String get fontSizeMedium => 'Среден';

  @override
  String get fontSizeLarge => 'Голям';

  @override
  String get apply => 'Приложи';

  @override
  String get dataManagement => 'Управление на данни';

  @override
  String get resetDataConfirmation =>
      'Сигурни ли сте, че искате да нулирате всички данни? Това действие не може да бъде отменено.';

  @override
  String get notificationSetting => 'Настройка на известия';

  @override
  String get category => 'Категория';

  @override
  String get selectExpenseTypeFirst => 'Първо изберете тип разход';

  @override
  String get errorLoadingCategories => 'Грешка при зареждане на категории';

  @override
  String get queryMonth => 'Месец на заявка';

  @override
  String get remainingAmount => 'Оставаща сума';

  @override
  String get todayExpenseMessageZero => 'Запишете днешните си разходи 😊';

  @override
  String get todayExpenseMessageGood => 'Страхотно! Имате още много бюджет 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'Използвахте почти половината! Нека бъдем по-внимателни сега 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'Близо сте до надвишаване на днешния бюджет! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'Надвишихте днешния бюджет! Нека коригираме разходите ❗';

  @override
  String get information => 'Информация';

  @override
  String get writeReview => 'Напиши отзив';

  @override
  String get appVersion => 'Версия на приложението';

  @override
  String get privacyPolicy => 'Политика за поверителност';

  @override
  String get basicSettings => 'Основни настройки';

  @override
  String get titleAndClose => 'Заглавие и затвори';

  @override
  String get filterSettings => 'Настройки на филтри';

  @override
  String get sort => 'Сортирай';

  @override
  String get latest => 'Най-нови';

  @override
  String get oldest => 'Най-стари';

  @override
  String get statistics => 'Статистики';

  @override
  String get spendingByCategory => 'Разходи по категории';

  @override
  String get top3ExpensesThisMonth => 'Топ 3 разхода този месец';

  @override
  String get home => 'Начало';

  @override
  String get daily => 'Дневно';

  @override
  String get monthly => 'Месечно';

  @override
  String get calendar => 'Календар';

  @override
  String get stats => 'Статистики';

  @override
  String get expense => 'Разходи';

  @override
  String get settings => 'Настройки';

  @override
  String get notificationTitleDaily => 'Напомняне за разходи';

  @override
  String get notificationBodyMorning =>
      'Добро утро! ☀️ Готови да запишете първия разход за деня? Малките навици правят голяма разлика!';

  @override
  String get notificationBodyAfternoon =>
      'Добър обяд? 🍱 Какво ще кажете за бърза актуализация на разходите?';

  @override
  String get notificationBodyNight =>
      'Денят почти свърши 🌙 Завършете го, като организирате разходите си.';

  @override
  String get resetComplete => 'Благодарим ви, че използвате MoneyFit.';

  @override
  String get upgraderTitle => 'Налична актуализация';

  @override
  String get upgraderBody =>
      'Налична е нова версия на приложението. Моля, актуализирайте за по-добро изживяване.';

  @override
  String get upgraderPrompt => 'Искате ли да актуализирате сега?';

  @override
  String get upgraderButtonLater => 'По-късно';

  @override
  String get upgraderButtonUpdate => 'Актуализирай сега';

  @override
  String get upgraderButtonIgnore => 'Игнорирай';

  @override
  String get updateRequiredTitle => 'Необходима актуализация';

  @override
  String get updateRequiredBody =>
      'Моля, актуализирайте до най-новата версия за най-добро изживяване.';

  @override
  String get updateAvailableBody =>
      'Налична е нова версия. Насладете се на най-новите функции и подобрения.';

  @override
  String get updateChangelogTitle => 'Какво ново';

  @override
  String get updateButton => 'Актуализирай';

  @override
  String get updateDetails => 'Подробности';

  @override
  String get updateSheetTitle => 'Информация за актуализация';

  @override
  String get updateButtonGo => 'Към актуализация';

  @override
  String get review_modal_binary_title =>
      'Доволни ли сте от приложението досега?';

  @override
  String get review_modal_button_good => 'Хареса ми';

  @override
  String get review_modal_button_bad => 'Не особено';

  @override
  String get review_positive_title => 'Можете ли да ни кажете какво ви хареса?';

  @override
  String get review_positive_button_yes => 'Разбира се';

  @override
  String get review_button_later => 'По-късно';

  @override
  String get review_button_never => 'Не показвай повече';

  @override
  String get review_negative_title => 'Кажете ни какво не работи за вас.';

  @override
  String get review_negative_hint => 'Кажете ни какво беше неудобно.';

  @override
  String get review_negative_button_send => 'Изпрати';

  @override
  String get review_thanks_message =>
      'Благодарим за обратната връзка. Ще работим за подобрение.';

  @override
  String get monthlyExpenseMessageZero =>
      'Все още няма дискреционни разходи този месец!';

  @override
  String get monthlyExpenseMessageGood =>
      'Бюджетът ви е добре управляван този месец!';

  @override
  String get monthlyExpenseMessageHalf =>
      'Използвахте около половината от бюджета си този месец.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Бюджетът ви е почти изчерпан този месец.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'Надвишихте бюджета си този месец.';

  @override
  String get contactUs => 'Свържете се с нас';

  @override
  String get inquiryType => 'Тип запитване';

  @override
  String get inquiryTypeBugReport => 'Докладване на грешка';

  @override
  String get inquiryTypeFeatureSuggestion => 'Предложение за функция';

  @override
  String get inquiryTypeGeneralInquiry => 'Общо запитване';

  @override
  String get inquiryTypeOther => 'Друго';

  @override
  String get replyEmail => 'Имейл за отговор';

  @override
  String get optional => 'По избор';

  @override
  String get inquiryDetails => 'Подробности за запитване';

  @override
  String get submit => 'Изпрати';

  @override
  String get inquirySuccess => 'Запитването ви беше изпратено успешно.';

  @override
  String get inquiryFailure => 'Неуспешно изпращане на запитване.';

  @override
  String get invalidEmail => 'Моля, въведете валиден имейл адрес.';

  @override
  String get fieldRequired => 'Това поле е задължително.';

  @override
  String get selectThemeColor => 'Избери цвят на темата';

  @override
  String get quickSelect => 'Бърз избор';

  @override
  String get recentColors => 'Последни цветове';

  @override
  String get customSelect => 'Персонализиран избор';

  @override
  String get close => 'Затвори';

  @override
  String get languageSetting => 'Език и валута';

  @override
  String get selectLanguage => 'Избери език';
}
