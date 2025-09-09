import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ko'),
    Locale('en'),
    Locale('fil'),
    Locale('ms'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MoneyFit'**
  String get appName;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'No More Complicated Spreadsheets'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'Easily manage your daily expenses and\nbuild healthy spending habits.'**
  String get onboardingDescription1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Daily Budget at a Glance'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Track your remaining budget for the day\nand start spending mindfully.'**
  String get onboardingDescription2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Turn Achievements into Lasting Habits'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Turn daily challenges into achievements\nand enjoy managing your money.'**
  String get onboardingDescription3;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @dailyBudgetSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Your Budget'**
  String get dailyBudgetSetupTitle;

  /// No description provided for @budgetSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Set your discretionary spending budget.\nDiscretionary spending is the amount you can use freely, excluding fixed costs like bills, medical expenses, housing, and insurance.'**
  String get budgetSetupDescription;

  /// No description provided for @dailyBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Budget'**
  String get dailyBudgetLabel;

  /// No description provided for @monthlyBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudgetLabel;

  /// No description provided for @enterBudgetPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter your budget.'**
  String get enterBudgetPrompt;

  /// No description provided for @enterValidNumberPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get enterValidNumberPrompt;

  /// No description provided for @budgetGreaterThanZeroPrompt.
  ///
  /// In en, this message translates to:
  /// **'Budget must be greater than 0.'**
  String get budgetGreaterThanZeroPrompt;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get start;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'MMMM d, yyyy EEEE'**
  String get dateFormat;

  /// No description provided for @dailyDiscretionarySpending.
  ///
  /// In en, this message translates to:
  /// **'Daily Discretionary Spending: '**
  String get dailyDiscretionarySpending;

  /// No description provided for @monthlyDiscretionarySpending2.
  ///
  /// In en, this message translates to:
  /// **'Monthly Discretionary Spending: '**
  String get monthlyDiscretionarySpending2;

  /// No description provided for @dailyBudget.
  ///
  /// In en, this message translates to:
  /// **'Daily Discretionary Budget: '**
  String get dailyBudget;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Discretionary Budget: '**
  String get monthlyBudget;

  /// No description provided for @monthlyAvgDiscSpending.
  ///
  /// In en, this message translates to:
  /// **'Disc/Day (Month)'**
  String get monthlyAvgDiscSpending;

  /// No description provided for @consecutiveDays.
  ///
  /// In en, this message translates to:
  /// **'Success Streak'**
  String get consecutiveDays;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days(Object count);

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'\$'**
  String get currency;

  /// No description provided for @viewTodaySpending.
  ///
  /// In en, this message translates to:
  /// **'View\nToday\'s Spending'**
  String get viewTodaySpending;

  /// No description provided for @totalSpendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No expenses yet} =1{1 expense} other{{count} expenses}}'**
  String totalSpendingCount(num count);

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add\nToday`s Expense'**
  String get addExpense;

  /// No description provided for @addNewExpensePrompt.
  ///
  /// In en, this message translates to:
  /// **'Add a new expense'**
  String get addNewExpensePrompt;

  /// No description provided for @notificationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll help you remember to log your expenses'**
  String get notificationDialogTitle;

  /// No description provided for @notificationDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Logging expenses is easy, but it\'s also easy to forget.\nWe\'ll send you daily reminders to help you stay on track. Would you like to receive notifications?'**
  String get notificationDialogDescription;

  /// No description provided for @notificationDialogDeny.
  ///
  /// In en, this message translates to:
  /// **'No, thanks'**
  String get notificationDialogDeny;

  /// No description provided for @notificationDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, please'**
  String get notificationDialogConfirm;

  /// No description provided for @category_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get category_food;

  /// No description provided for @category_traffic.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get category_traffic;

  /// No description provided for @category_insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get category_insurance;

  /// No description provided for @category_necessities.
  ///
  /// In en, this message translates to:
  /// **'Necessities'**
  String get category_necessities;

  /// No description provided for @category_communication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get category_communication;

  /// No description provided for @category_housing.
  ///
  /// In en, this message translates to:
  /// **'Housing/Utilities'**
  String get category_housing;

  /// No description provided for @category_medical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get category_medical;

  /// No description provided for @category_finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get category_finance;

  /// No description provided for @categoryEatingOut.
  ///
  /// In en, this message translates to:
  /// **'Eating Out'**
  String get categoryEatingOut;

  /// No description provided for @category_cafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe/Snacks'**
  String get category_cafe;

  /// No description provided for @category_shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get category_shopping;

  /// No description provided for @category_hobby.
  ///
  /// In en, this message translates to:
  /// **'Hobby/Leisure'**
  String get category_hobby;

  /// No description provided for @category_travel.
  ///
  /// In en, this message translates to:
  /// **'Travel/Relaxation'**
  String get category_travel;

  /// No description provided for @category_subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get category_subscribe;

  /// No description provided for @category_beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get category_beauty;

  /// No description provided for @expenseType_essential.
  ///
  /// In en, this message translates to:
  /// **'Essential'**
  String get expenseType_essential;

  /// No description provided for @expenseType_discretionary.
  ///
  /// In en, this message translates to:
  /// **'Discretionary'**
  String get expenseType_discretionary;

  /// No description provided for @dailyExpenseHistory.
  ///
  /// In en, this message translates to:
  /// **'Daily Expense History'**
  String get dailyExpenseHistory;

  /// No description provided for @noExpenseHistory.
  ///
  /// In en, this message translates to:
  /// **'No expense history found.'**
  String get noExpenseHistory;

  /// No description provided for @editDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit/Delete Expense'**
  String get editDeleteExpense;

  /// No description provided for @editDeleteExpensePrompt.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do with the expense \"{expenseName}\"'**
  String editDeleteExpensePrompt(Object expenseName);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @allExpenses.
  ///
  /// In en, this message translates to:
  /// **'All Expenses'**
  String get allExpenses;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Asc'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Desc'**
  String get descending;

  /// No description provided for @noExpenseData.
  ///
  /// In en, this message translates to:
  /// **'No expense data exists'**
  String get noExpenseData;

  /// No description provided for @changeFilterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Try changing the filter conditions or\nadd a new expense'**
  String get changeFilterPrompt;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter all fields correctly.'**
  String get allFieldsRequired;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryPrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the category \'{categoryName}\''**
  String deleteCategoryPrompt(Object categoryName);

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @noDataExists.
  ///
  /// In en, this message translates to:
  /// **'No data exists.'**
  String get noDataExists;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'{year}'**
  String yearLabel(Object year);

  /// No description provided for @monthLabel.
  ///
  /// In en, this message translates to:
  /// **'{month}'**
  String monthLabel(Object month);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @budgetSetting.
  ///
  /// In en, this message translates to:
  /// **'Budget Setting'**
  String get budgetSetting;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @resetInformation.
  ///
  /// In en, this message translates to:
  /// **'Reset Information'**
  String get resetInformation;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Required'**
  String get notificationPermissionRequired;

  /// No description provided for @notificationPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'To use notification features, please allow notification permissions in settings.'**
  String get notificationPermissionDescription;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @monthlyDiscretionarySpending.
  ///
  /// In en, this message translates to:
  /// **'Discretionary'**
  String get monthlyDiscretionarySpending;

  /// No description provided for @monthlyEssentialSpending.
  ///
  /// In en, this message translates to:
  /// **'Essential'**
  String get monthlyEssentialSpending;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failure.
  ///
  /// In en, this message translates to:
  /// **'Failure'**
  String get failure;

  /// No description provided for @consecutiveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get consecutiveSuccess;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(Object count);

  /// No description provided for @yearMonth.
  ///
  /// In en, this message translates to:
  /// **'{month} {year}'**
  String yearMonth(Object month, Object year);

  /// No description provided for @nameIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name is empty.'**
  String get nameIsEmpty;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount is invalid or less than or equal to 0.'**
  String get invalidAmount;

  /// No description provided for @categoryNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Category not selected.'**
  String get categoryNotSelected;

  /// No description provided for @formValidationError.
  ///
  /// In en, this message translates to:
  /// **'Form validation error: {error}'**
  String formValidationError(Object error);

  /// No description provided for @registerExpense.
  ///
  /// In en, this message translates to:
  /// **'Register Expense'**
  String get registerExpense;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @expenseName.
  ///
  /// In en, this message translates to:
  /// **'Expense Name'**
  String get expenseName;

  /// No description provided for @enterExpenseName.
  ///
  /// In en, this message translates to:
  /// **'Please enter expense name'**
  String get enterExpenseName;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @enterExpenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter expense amount'**
  String get enterExpenseAmount;

  /// No description provided for @expenseType.
  ///
  /// In en, this message translates to:
  /// **'Expense Type'**
  String get expenseType;

  /// No description provided for @essentialExpense.
  ///
  /// In en, this message translates to:
  /// **'Essential'**
  String get essentialExpense;

  /// No description provided for @discretionaryExpense.
  ///
  /// In en, this message translates to:
  /// **'Discretionary'**
  String get discretionaryExpense;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(Object error);

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @resetDataConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all data? This action cannot be undone.'**
  String get resetDataConfirmation;

  /// No description provided for @notificationSetting.
  ///
  /// In en, this message translates to:
  /// **'Notification Setting'**
  String get notificationSetting;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectExpenseTypeFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select expense type first'**
  String get selectExpenseTypeFirst;

  /// No description provided for @errorLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get errorLoadingCategories;

  /// No description provided for @queryMonth.
  ///
  /// In en, this message translates to:
  /// **'Query Month'**
  String get queryMonth;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get remainingAmount;

  /// No description provided for @todayExpenseMessageZero.
  ///
  /// In en, this message translates to:
  /// **'Please log your expenses today 😊'**
  String get todayExpenseMessageZero;

  /// No description provided for @todayExpenseMessageGood.
  ///
  /// In en, this message translates to:
  /// **'Great! You still have plenty of budget left 🌿'**
  String get todayExpenseMessageGood;

  /// No description provided for @todayExpenseMessageHalf.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used almost half!\nLet\'s be a little more mindful now 🔔'**
  String get todayExpenseMessageHalf;

  /// No description provided for @todayExpenseMessageNearLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'re close to exceeding today\'s budget! ⚠️'**
  String get todayExpenseMessageNearLimit;

  /// No description provided for @todayExpenseMessageOverLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve exceeded today\'s budget!\nLet\'s adjust your spending ❗'**
  String get todayExpenseMessageOverLimit;

  /// No description provided for @information.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @basicSettings.
  ///
  /// In en, this message translates to:
  /// **'Basic Settings'**
  String get basicSettings;

  /// No description provided for @titleAndClose.
  ///
  /// In en, this message translates to:
  /// **'Title & Close'**
  String get titleAndClose;

  /// No description provided for @filterSettings.
  ///
  /// In en, this message translates to:
  /// **'Filter Settings'**
  String get filterSettings;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// No description provided for @top3ExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Top 3 Expenses This Month'**
  String get top3ExpensesThisMonth;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notificationTitleDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Expense Reminder'**
  String get notificationTitleDaily;

  /// No description provided for @notificationBodyMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning ☀️ Ready to log your first expense of the day? Small habits make a big difference!'**
  String get notificationBodyMorning;

  /// No description provided for @notificationBodyAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Enjoyed your lunch? 🍱 How about a quick update on your expenses?'**
  String get notificationBodyAfternoon;

  /// No description provided for @notificationBodyNight.
  ///
  /// In en, this message translates to:
  /// **'The day is almost over 🌙 Wrap up your day by organizing your expenses.'**
  String get notificationBodyNight;

  /// No description provided for @resetComplete.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using MoneyFit.'**
  String get resetComplete;

  /// No description provided for @upgraderTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get upgraderTitle;

  /// No description provided for @upgraderBody.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update for a better experience.'**
  String get upgraderBody;

  /// No description provided for @upgraderPrompt.
  ///
  /// In en, this message translates to:
  /// **'Would you like to update now?'**
  String get upgraderPrompt;

  /// No description provided for @upgraderButtonLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get upgraderButtonLater;

  /// No description provided for @upgraderButtonUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get upgraderButtonUpdate;

  /// No description provided for @upgraderButtonIgnore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get upgraderButtonIgnore;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Please update to the latest version for the best experience.'**
  String get updateRequiredBody;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'A new version is available. Enjoy the latest features and improvements.'**
  String get updateAvailableBody;

  /// No description provided for @updateChangelogTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get updateChangelogTitle;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @updateDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get updateDetails;

  /// No description provided for @updateSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Info'**
  String get updateSheetTitle;

  /// No description provided for @updateButtonGo.
  ///
  /// In en, this message translates to:
  /// **'Go to Update'**
  String get updateButtonGo;

  /// No description provided for @review_modal_binary_title.
  ///
  /// In en, this message translates to:
  /// **'Are you satisfied with the app so far?'**
  String get review_modal_binary_title;

  /// No description provided for @review_modal_button_good.
  ///
  /// In en, this message translates to:
  /// **'I liked it'**
  String get review_modal_button_good;

  /// No description provided for @review_modal_button_bad.
  ///
  /// In en, this message translates to:
  /// **'Not really'**
  String get review_modal_button_bad;

  /// No description provided for @review_positive_title.
  ///
  /// In en, this message translates to:
  /// **'Could you tell us what you liked?'**
  String get review_positive_title;

  /// No description provided for @review_positive_button_yes.
  ///
  /// In en, this message translates to:
  /// **'Sure'**
  String get review_positive_button_yes;

  /// No description provided for @review_button_later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get review_button_later;

  /// No description provided for @review_button_never.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get review_button_never;

  /// No description provided for @review_negative_title.
  ///
  /// In en, this message translates to:
  /// **'Please let us know what didn\'t work for you.'**
  String get review_negative_title;

  /// No description provided for @review_negative_hint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what was inconvenient.'**
  String get review_negative_hint;

  /// No description provided for @review_negative_button_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get review_negative_button_send;

  /// No description provided for @review_thanks_message.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback. We\'ll work to improve it.'**
  String get review_thanks_message;

  /// No description provided for @monthlyExpenseMessageZero.
  ///
  /// In en, this message translates to:
  /// **'No discretionary spending this month yet!'**
  String get monthlyExpenseMessageZero;

  /// No description provided for @monthlyExpenseMessageGood.
  ///
  /// In en, this message translates to:
  /// **'Your budget is well-managed this month!'**
  String get monthlyExpenseMessageGood;

  /// No description provided for @monthlyExpenseMessageHalf.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used about half of your budget this month.'**
  String get monthlyExpenseMessageHalf;

  /// No description provided for @monthlyExpenseMessageNearLimit.
  ///
  /// In en, this message translates to:
  /// **'Your budget is almost used up for this month.'**
  String get monthlyExpenseMessageNearLimit;

  /// No description provided for @monthlyExpenseMessageOverLimit.
  ///
  /// In en, this message translates to:
  /// **'You have exceeded your budget for this month.'**
  String get monthlyExpenseMessageOverLimit;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @inquiryType.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Type'**
  String get inquiryType;

  /// No description provided for @inquiryTypeBugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get inquiryTypeBugReport;

  /// No description provided for @inquiryTypeFeatureSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Feature Suggestion'**
  String get inquiryTypeFeatureSuggestion;

  /// No description provided for @inquiryTypeGeneralInquiry.
  ///
  /// In en, this message translates to:
  /// **'General Inquiry'**
  String get inquiryTypeGeneralInquiry;

  /// No description provided for @inquiryTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get inquiryTypeOther;

  /// No description provided for @replyEmail.
  ///
  /// In en, this message translates to:
  /// **'Email for reply'**
  String get replyEmail;

  /// No description provided for @inquiryDetails.
  ///
  /// In en, this message translates to:
  /// **'Inquiry Details'**
  String get inquiryDetails;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @inquirySuccess.
  ///
  /// In en, this message translates to:
  /// **'Your inquiry has been submitted successfully.'**
  String get inquirySuccess;

  /// No description provided for @inquiryFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit your inquiry.'**
  String get inquiryFailure;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fil', 'id', 'ko', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
    case 'id':
      return AppLocalizationsId();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
