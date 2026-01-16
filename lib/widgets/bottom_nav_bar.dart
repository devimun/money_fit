import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_fit/core/providers/navigation_provider.dart';
import 'package:money_fit/core/providers/select_date_provider.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class MainBottomNavBar extends ConsumerWidget {
  const MainBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
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
        onTap: () => _onTap(context, ref, index, currentIndex),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
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

  void _onTap(
    BuildContext context,
    WidgetRef ref,
    int index,
    int currentIndex,
  ) {
    if (index == currentIndex) return;
    ref.read(navigationIndexProvider.notifier).state = index;
    ref.read(dateManager.notifier).changeDate(DateTime.now());
    if ([1, 2, 3].contains(index)) {
      InterstitialAdManager.instance.logActionAndShowAd();
    }
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/calendar');
        break;
      case 2:
        context.go('/stats');
        break;
      case 3:
        context.go('/expense_list');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}
