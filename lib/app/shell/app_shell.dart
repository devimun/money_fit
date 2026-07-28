import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/app/router/analytics_navigation_observer.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/features/app_update/presentation/recommended_update_prompt.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    required this.navigationShell,
    required this.screenViewTracker,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final AnalyticsScreenViewTracker screenViewTracker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RecommendedUpdatePrompt(
      child: Scaffold(
        // Every tab shares this shell. Consume the top system inset here so a
        // screen cannot accidentally render under the status bar on edge-to-edge
        // Android versions. The navigation bar owns its own bottom SafeArea.
        body: SafeArea(bottom: false, child: navigationShell),
        bottomNavigationBar: MainBottomNavBar(
          navigationShell: navigationShell,
          screenViewTracker: screenViewTracker,
        ),
      ),
    );
  }
}

class MainBottomNavBar extends ConsumerWidget {
  const MainBottomNavBar({
    required this.navigationShell,
    required this.screenViewTracker,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final AnalyticsScreenViewTracker screenViewTracker;

  static const _screenNames = <String>[
    'home',
    'calendar',
    'statistics',
    'expense_list',
    'settings',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                ref: ref,
                index: 0,
                icon: Icons.home,
                label: l10n.home,
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                ref: ref,
                index: 1,
                icon: Icons.calendar_today,
                label: l10n.calendar,
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                ref: ref,
                index: 2,
                icon: Icons.assessment_outlined,
                label: l10n.stats,
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                ref: ref,
                index: 3,
                icon: Icons.receipt_long,
                label: l10n.expense,
                currentIndex: currentIndex,
              ),
              _buildNavItem(
                context: context,
                ref: ref,
                index: 4,
                icon: Icons.settings,
                label: l10n.settings,
                currentIndex: currentIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required IconData icon,
    required String label,
    required int currentIndex,
  }) {
    final theme = Theme.of(context);
    final isSelected = index == currentIndex;
    final colorScheme = theme.colorScheme;

    final color = isSelected
        ? (theme.bottomNavigationBarTheme.selectedItemColor ??
              colorScheme.primary)
        : (theme.bottomNavigationBarTheme.unselectedItemColor ??
              colorScheme.onSurface.withValues(alpha: 0.6));

    return Expanded(
      child: InkWell(
        onTap: () => _onTap(ref, index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            ResponsiveNavText(
              text: label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(WidgetRef ref, int index) {
    final currentIndex = navigationShell.currentIndex;
    final destinationChanged = isPrimaryDestinationChange(
      currentIndex: currentIndex,
      destinationIndex: index,
    );
    navigationShell.goBranch(index, initialLocation: !destinationChanged);
    if (!destinationChanged) return;

    // A first visit is already reported by its branch observer. A restored
    // branch has no Navigator push, so report it after the frame and let the
    // shared tracker de-duplicate either ordering.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenViewTracker.trackScreen(
        _screenNames[index],
        navigationType: 'branch_switch',
      );
    });
    unawaited(
      ref.read(monetizationSafePointProvider)(
        MeaningfulAdAction.primaryDestinationChanged,
      ),
    );
  }
}

/// A selected primary destination is a tab reselect, not a transition.
/// Keeping this boundary explicit prevents an action or safe point from being
/// emitted for reselects that merely restore a branch's initial location.
bool isPrimaryDestinationChange({
  required int currentIndex,
  required int destinationIndex,
}) => currentIndex != destinationIndex;
