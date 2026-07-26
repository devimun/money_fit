import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/config/feedback_prompt_config.dart';
import 'package:money_fit/core/config/remote_config_service.dart';
import 'package:money_fit/core/repositories/feedback_repository.dart';
import 'package:money_fit/core/repositories/prompt_state_repository.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';
import 'package:money_fit/core/services/feedback_prompt_service.dart';
import 'package:money_fit/core/services/prompt_coordinator.dart';

final promptCoordinatorProvider = Provider<PromptCoordinator>(
  (ref) => PromptCoordinator(),
);
final promptStateRepositoryProvider = Provider<PromptStateRepository>(
  (ref) => PromptStateRepository(ref.watch(sharedPreferencesProvider)),
);
final feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (ref) => FeedbackRepository(),
);
final remoteConfigServiceProvider = Provider<RemoteConfigService>(
  (ref) => throw UnimplementedError('RemoteConfigService must be overridden'),
);
final feedbackPromptServiceProvider = Provider<FeedbackPromptService>(
  (ref) => FeedbackPromptService(
    ref.watch(promptStateRepositoryProvider),
    FeedbackPromptConfig.fromRemoteConfig(
      ref.watch(remoteConfigServiceProvider),
    ),
  ),
);
