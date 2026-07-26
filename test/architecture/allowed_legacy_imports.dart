/// Compatibility exceptions that existed before the architecture migration.
///
/// Every entry is intentionally narrow: a new import, singleton use, or UI
/// type reference must either remove an entry in its planned phase or add a
/// separately reviewed exception here.
enum LegacyBoundaryKind { coreToFeatureImport, sdkSingleton, serviceUiType }

enum LegacyOwner {
  appComposition,
  ledger,
  budget,
  session,
  notifications,
  reset,
  appUpdate,
  feedback,
}

enum RemovalPhase {
  pr2_1,
  pr2_3,
  pr3_2,
  pr4_1,
  pr5_1,
  pr5_3,
  pr5_4,
  pr6_1,
  pr6_3,
}

class LegacyBoundaryAllowance {
  const LegacyBoundaryAllowance({
    required this.filePath,
    required this.kind,
    required this.target,
    required this.reason,
    required this.owner,
    required this.removalPhase,
    this.expectedOccurrences = 1,
  });

  final String filePath;
  final LegacyBoundaryKind kind;
  final String target;
  final String reason;
  final LegacyOwner owner;
  final RemovalPhase removalPhase;
  final int expectedOccurrences;

  @override
  String toString() =>
      '$filePath: $target (${kind.name}; ${owner.name}; ${removalPhase.name})';
}

const allowedLegacyImports = <LegacyBoundaryAllowance>[
  // core -> feature imports (12 import directives from six legacy files).
  LegacyBoundaryAllowance(
    filePath: 'lib/core/providers/category_providers.dart',
    kind: LegacyBoundaryKind.coreToFeatureImport,
    target:
        'package:money_fit/features/settings/viewmodel/user_settings_provider.dart',
    reason: 'Category state reads the legacy settings-owned user identity.',
    owner: LegacyOwner.ledger,
    removalPhase: RemovalPhase.pr3_2,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/core/providers/expenses_provider.dart',
    kind: LegacyBoundaryKind.coreToFeatureImport,
    target:
        'package:money_fit/features/settings/viewmodel/user_settings_provider.dart',
    reason: 'Expense state reads the legacy settings-owned user identity.',
    owner: LegacyOwner.ledger,
    removalPhase: RemovalPhase.pr3_2,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/core/services/app_initializer.dart',
    kind: LegacyBoundaryKind.coreToFeatureImport,
    target: 'package:money_fit/features/home/viewmodel/home_data_provider.dart',
    reason: 'Legacy startup preloads the home ViewModel directly.',
    owner: LegacyOwner.appComposition,
    removalPhase: RemovalPhase.pr6_1,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/core/services/notification_service.dart',
    kind: LegacyBoundaryKind.coreToFeatureImport,
    target:
        'package:money_fit/features/settings/viewmodel/user_settings_provider.dart',
    reason: 'Notification permission still writes through settings state.',
    owner: LegacyOwner.notifications,
    removalPhase: RemovalPhase.pr5_3,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/core/widgets/today_expense_list.dart',
    kind: LegacyBoundaryKind.coreToFeatureImport,
    target: 'package:money_fit/features/home/viewmodel/home_data_provider.dart',
    reason: 'The core widget still consumes home presentation state.',
    owner: LegacyOwner.ledger,
    removalPhase: RemovalPhase.pr3_2,
  ),

  // Direct SDK/database singletons outside main/app composition.
  LegacyBoundaryAllowance(
    filePath: 'lib/core/services/app_initializer.dart',
    kind: LegacyBoundaryKind.sdkSingleton,
    target: 'FirebaseRemoteConfig.instance',
    reason: 'Bootstrap still configures Remote Config directly.',
    owner: LegacyOwner.appComposition,
    removalPhase: RemovalPhase.pr6_1,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/core/services/data_reset_service.dart',
    kind: LegacyBoundaryKind.sdkSingleton,
    target: 'FirebaseAnalytics.instance',
    reason: 'Reset coordination has not yet isolated analytics.',
    owner: LegacyOwner.reset,
    removalPhase: RemovalPhase.pr5_4,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/core/services/data_reset_service.dart',
    kind: LegacyBoundaryKind.sdkSingleton,
    target: 'DatabaseHelper.instance',
    reason: 'Reset still deletes the legacy v5 database directly.',
    owner: LegacyOwner.reset,
    removalPhase: RemovalPhase.pr5_4,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/core/services/review_prompt_service.dart',
    kind: LegacyBoundaryKind.sdkSingleton,
    target: 'Supabase.instance',
    reason: 'Feedback submission has not moved behind its repository.',
    owner: LegacyOwner.feedback,
    removalPhase: RemovalPhase.pr6_3,
    expectedOccurrences: 2,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/core/services/update_service.dart',
    kind: LegacyBoundaryKind.sdkSingleton,
    target: 'FirebaseRemoteConfig.instance',
    reason: 'The app-update adapter has not yet been extracted.',
    owner: LegacyOwner.appUpdate,
    removalPhase: RemovalPhase.pr6_3,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/features/onboarding/view/budget_setup_screen.dart',
    kind: LegacyBoundaryKind.sdkSingleton,
    target: 'FirebaseAnalytics.instance',
    reason: 'Budget presentation still emits analytics directly.',
    owner: LegacyOwner.budget,
    removalPhase: RemovalPhase.pr4_1,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/features/settings/viewmodel/user_settings_provider.dart',
    kind: LegacyBoundaryKind.sdkSingleton,
    target: 'Supabase.instance',
    reason: 'Session identity is still owned by the settings ViewModel.',
    owner: LegacyOwner.session,
    removalPhase: RemovalPhase.pr5_1,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/features/settings/widgets/contact_us_dialog.dart',
    kind: LegacyBoundaryKind.sdkSingleton,
    target: 'Supabase.instance',
    reason: 'Feedback presentation still sends directly to Supabase.',
    owner: LegacyOwner.feedback,
    removalPhase: RemovalPhase.pr6_3,
    expectedOccurrences: 2,
  ),

  // data/service UI references.
  LegacyBoundaryAllowance(
    filePath: 'lib/core/services/notification_service.dart',
    kind: LegacyBoundaryKind.serviceUiType,
    target: 'BuildContext',
    reason: 'Notification permission currently displays a dialog itself.',
    owner: LegacyOwner.notifications,
    removalPhase: RemovalPhase.pr5_3,
    expectedOccurrences: 2,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/core/services/notification_service.dart',
    kind: LegacyBoundaryKind.serviceUiType,
    target: 'WidgetRef',
    reason: 'Notification permission currently mutates settings state itself.',
    owner: LegacyOwner.notifications,
    removalPhase: RemovalPhase.pr5_3,
    expectedOccurrences: 2,
  ),
  LegacyBoundaryAllowance(
    filePath: 'lib/core/services/review_prompt_service.dart',
    kind: LegacyBoundaryKind.serviceUiType,
    target: 'BuildContext',
    reason: 'Review prompting currently owns dialog presentation.',
    owner: LegacyOwner.feedback,
    removalPhase: RemovalPhase.pr6_3,
  ),
];
