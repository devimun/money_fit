import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';

class BaseBottomSheet extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget child;
  final Widget? footer;

  const BaseBottomSheet({
    super.key,
    required this.title,
    required this.onClose,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ${l10n.titleAndClose}
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: context.textTheme.titleMedium),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
            Divider(
              color: context.colors.divider,
              height: 1,
            ),
            const SizedBox(height: 20),

            /// 본문
            Expanded(child: child),

            /// 하단 버튼
            if (footer != null) ...[const SizedBox(height: 16), footer!],
          ],
        ),
      ),
    );
  }
}
