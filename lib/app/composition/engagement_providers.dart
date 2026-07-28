import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';

/// One app-wide arbiter for prompts and fullscreen ads.
final promptCoordinatorProvider = Provider<PromptCoordinator>(
  (ref) => PromptCoordinator(now: ref.watch(clockProvider).now),
);
