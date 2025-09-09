// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MoneyFit';

  @override
  String get onboardingTitle1 => 'No More Complicated Spreadsheets';

  @override
  String get onboardingDescription1 =>
      'Easily manage your daily expenses and\nbuild healthy spending habits.';

  @override
  String get onboardingTitle2 => 'Daily Budget at a Glance';

  @override
  String get onboardingDescription2 =>
      'Track your remaining budget for the day\nand start spending mindfully.';

  @override
  String get onboardingTitle3 => 'Turn Achievements into Lasting Habits';

  @override
  String get onboardingDescription3 =>
      'Turn daily challenges into achievements\nand enjoy managing your money.';

  @override
  String get next => 'Next';

  @override
  String get dailyBudgetSetupTitle => 'Set Your Budget';

  @override
  String get budgetSetupDescription =>
      'Set your discretionary spending budget.\nDiscretionary spending is the amount you can use freely, excluding fixed costs like bills, medical expenses, housing, and insurance.';

  @override
  String get dailyBudgetLabel => 'Daily Budget';

  @override
  String get monthlyBudgetLabel => 'Monthly Budget';

  @override
  String get enterBudgetPrompt => 'Please enter your budget.';

  @override
  String get enterValidNumberPrompt => 'Please enter a valid number.';

  @override
  String get budgetGreaterThanZeroPrompt => 'Budget must be greater than 0.';

  @override
  String get start => 'Get Started';

  @override
  String errorOccurred(Object error) {
    return 'An error occurred: $error';
  }

  @override
  String get dateFormat => 'MMMM d, yyyy EEEE';

  @override
  String get dailyDiscretionarySpending => 'Daily Discretionary Spending: ';

  @override
  String get monthlyDiscretionarySpending2 =>
      'Monthly Discretionary Spending: ';

  @override
  String get dailyBudget => 'Daily Discretionary Budget: ';

  @override
  String get monthlyBudget => 'Monthly Discretionary Budget: ';

  @override
  String get monthlyAvgDiscSpending => 'Disc/Day (Month)';

  @override
  String get consecutiveDays => 'Success Streak';

  @override
  String days(Object count) {
    return '$count days';
  }

  @override
  String get currency => '\$';

  @override
  String get viewTodaySpending => 'View\nToday\'s Spending';

  @override
  String totalSpendingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
      zero: 'No expenses yet',
    );
    return '$_temp0';
  }

  @override
  String get addExpense => 'Add\nToday`s Expense';

  @override
  String get addNewExpensePrompt => 'Add a new expense';

  @override
  String get notificationDialogTitle =>
      'We\'ll help you remember to log your expenses';

  @override
  String get notificationDialogDescription =>
      'Logging expenses is easy, but it\'s also easy to forget.\nWe\'ll send you daily reminders to help you stay on track. Would you like to receive notifications?';

  @override
  String get notificationDialogDeny => 'No, thanks';

  @override
  String get notificationDialogConfirm => 'Yes, please';

  @override
  String get category_food => 'Food';

  @override
  String get category_traffic => 'Traffic';

  @override
  String get category_insurance => 'Insurance';

  @override
  String get category_necessities => 'Necessities';

  @override
  String get category_communication => 'Communication';

  @override
  String get category_housing => 'Housing/Utilities';

  @override
  String get category_medical => 'Medical';

  @override
  String get category_finance => 'Finance';

  @override
  String get categoryEatingOut => 'Eating Out';

  @override
  String get category_cafe => 'Cafe/Snacks';

  @override
  String get category_shopping => 'Shopping';

  @override
  String get category_hobby => 'Hobby/Leisure';

  @override
  String get category_travel => 'Travel/Relaxation';

  @override
  String get category_subscribe => 'Subscription';

  @override
  String get category_beauty => 'Beauty';

  @override
  String get expenseType_essential => 'Essential';

  @override
  String get expenseType_discretionary => 'Discretionary';

  @override
  String get dailyExpenseHistory => 'Daily Expense History';

  @override
  String get noExpenseHistory => 'No expense history found.';

  @override
  String get editDeleteExpense => 'Edit/Delete Expense';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return 'What would you like to do with the expense \"$expenseName\"';
  }

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get allExpenses => 'All Expenses';

  @override
  String get allCategories => 'All Categories';

  @override
  String get unknown => 'Unknown';

  @override
  String get ascending => 'Asc';

  @override
  String get descending => 'Desc';

  @override
  String get noExpenseData => 'No expense data exists';

  @override
  String get changeFilterPrompt =>
      'Try changing the filter conditions or\nadd a new expense';

  @override
  String get allFieldsRequired => 'Please enter all fields correctly.';

  @override
  String get addNewCategory => 'Add New Category';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return 'Are you sure you want to delete the category \'$categoryName\'';
  }

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get noDataExists => 'No data exists.';

  @override
  String get reset => 'Reset';

  @override
  String get selectDate => 'Select Date';

  @override
  String yearLabel(Object year) {
    return '$year';
  }

  @override
  String monthLabel(Object month) {
    return '$month';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get budgetSetting => 'Budget Setting';

  @override
  String get save => 'Save';

  @override
  String get resetInformation => 'Reset Information';

  @override
  String get notificationPermissionRequired =>
      'Notification Permission Required';

  @override
  String get notificationPermissionDescription =>
      'To use notification features, please allow notification permissions in settings.';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get monthlyDiscretionarySpending => 'Discretionary';

  @override
  String get monthlyEssentialSpending => 'Essential';

  @override
  String get success => 'Success';

  @override
  String get failure => 'Failure';

  @override
  String get consecutiveSuccess => 'Streak';

  @override
  String daysCount(Object count) {
    return '$count days';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get nameIsEmpty => 'Name is empty.';

  @override
  String get invalidAmount => 'Amount is invalid or less than or equal to 0.';

  @override
  String get categoryNotSelected => 'Category not selected.';

  @override
  String formValidationError(Object error) {
    return 'Form validation error: $error';
  }

  @override
  String get registerExpense => 'Register Expense';

  @override
  String get register => 'Register';

  @override
  String get date => 'Date';

  @override
  String get expenseName => 'Expense Name';

  @override
  String get enterExpenseName => 'Please enter expense name';

  @override
  String get amount => 'Amount';

  @override
  String get enterExpenseAmount => 'Please enter expense amount';

  @override
  String get expenseType => 'Expense Type';

  @override
  String get essentialExpense => 'Essential';

  @override
  String get discretionaryExpense => 'Discretionary';

  @override
  String get categoryName => 'Category Name';

  @override
  String get sunday => 'Sun';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String errorWithMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get apply => 'Apply';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get resetDataConfirmation =>
      'Are you sure you want to reset all data? This action cannot be undone.';

  @override
  String get notificationSetting => 'Notification Setting';

  @override
  String get category => 'Category';

  @override
  String get selectExpenseTypeFirst => 'Please select expense type first';

  @override
  String get errorLoadingCategories => 'Error loading categories';

  @override
  String get queryMonth => 'Query Month';

  @override
  String get remainingAmount => 'Remaining Amount';

  @override
  String get todayExpenseMessageZero => 'Please log your expenses today 😊';

  @override
  String get todayExpenseMessageGood =>
      'Great! You still have plenty of budget left 🌿';

  @override
  String get todayExpenseMessageHalf =>
      'You\'ve used almost half!\nLet\'s be a little more mindful now 🔔';

  @override
  String get todayExpenseMessageNearLimit =>
      'You\'re close to exceeding today\'s budget! ⚠️';

  @override
  String get todayExpenseMessageOverLimit =>
      'You\'ve exceeded today\'s budget!\nLet\'s adjust your spending ❗';

  @override
  String get information => 'Information';

  @override
  String get writeReview => 'Write a Review';

  @override
  String get appVersion => 'App Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get basicSettings => 'Basic Settings';

  @override
  String get titleAndClose => 'Title & Close';

  @override
  String get filterSettings => 'Filter Settings';

  @override
  String get sort => 'Sort';

  @override
  String get latest => 'Latest';

  @override
  String get oldest => 'Oldest';

  @override
  String get statistics => 'Statistics';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get top3ExpensesThisMonth => 'Top 3 Expenses This Month';

  @override
  String get home => 'Home';

  @override
  String get daily => 'Daily';

  @override
  String get monthly => 'Monthly';

  @override
  String get calendar => 'Calendar';

  @override
  String get stats => 'Stats';

  @override
  String get expense => 'Expense';

  @override
  String get settings => 'Settings';

  @override
  String get notificationTitleDaily => 'Daily Expense Reminder';

  @override
  String get notificationBodyMorning =>
      'Good morning ☀️ Ready to log your first expense of the day? Small habits make a big difference!';

  @override
  String get notificationBodyAfternoon =>
      'Enjoyed your lunch? 🍱 How about a quick update on your expenses?';

  @override
  String get notificationBodyNight =>
      'The day is almost over 🌙 Wrap up your day by organizing your expenses.';

  @override
  String get resetComplete => 'Thank you for using MoneyFit.';

  @override
  String get upgraderTitle => 'Update Available';

  @override
  String get upgraderBody =>
      'A new version of the app is available. Please update for a better experience.';

  @override
  String get upgraderPrompt => 'Would you like to update now?';

  @override
  String get upgraderButtonLater => 'Later';

  @override
  String get upgraderButtonUpdate => 'Update Now';

  @override
  String get upgraderButtonIgnore => 'Ignore';

  @override
  String get updateRequiredTitle => 'Update Required';

  @override
  String get updateRequiredBody =>
      'Please update to the latest version for the best experience.';

  @override
  String get updateAvailableBody =>
      'A new version is available. Enjoy the latest features and improvements.';

  @override
  String get updateChangelogTitle => 'What\'s New';

  @override
  String get updateButton => 'Update';

  @override
  String get updateDetails => 'Details';

  @override
  String get updateSheetTitle => 'Update Info';

  @override
  String get updateButtonGo => 'Go to Update';

  @override
  String get review_modal_binary_title =>
      'Are you satisfied with the app so far?';

  @override
  String get review_modal_button_good => 'I liked it';

  @override
  String get review_modal_button_bad => 'Not really';

  @override
  String get review_positive_title => 'Could you tell us what you liked?';

  @override
  String get review_positive_button_yes => 'Sure';

  @override
  String get review_button_later => 'Later';

  @override
  String get review_button_never => 'Don\'t show again';

  @override
  String get review_negative_title =>
      'Please let us know what didn\'t work for you.';

  @override
  String get review_negative_hint => 'Tell us what was inconvenient.';

  @override
  String get review_negative_button_send => 'Send';

  @override
  String get review_thanks_message =>
      'Thank you for your feedback. We\'ll work to improve it.';

  @override
  String get monthlyExpenseMessageZero =>
      'No discretionary spending this month yet!';

  @override
  String get monthlyExpenseMessageGood =>
      'Your budget is well-managed this month!';

  @override
  String get monthlyExpenseMessageHalf =>
      'You\'ve used about half of your budget this month.';

  @override
  String get monthlyExpenseMessageNearLimit =>
      'Your budget is almost used up for this month.';

  @override
  String get monthlyExpenseMessageOverLimit =>
      'You have exceeded your budget for this month.';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get inquiryType => 'Inquiry Type';

  @override
  String get inquiryTypeBugReport => 'Bug Report';

  @override
  String get inquiryTypeFeatureSuggestion => 'Feature Suggestion';

  @override
  String get inquiryTypeGeneralInquiry => 'General Inquiry';

  @override
  String get inquiryTypeOther => 'Other';

  @override
  String get replyEmail => 'Email for reply';

  @override
  String get inquiryDetails => 'Inquiry Details';

  @override
  String get submit => 'Submit';

  @override
  String get inquirySuccess => 'Your inquiry has been submitted successfully.';

  @override
  String get inquiryFailure => 'Failed to submit your inquiry.';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get fieldRequired => 'This field is required.';
}
