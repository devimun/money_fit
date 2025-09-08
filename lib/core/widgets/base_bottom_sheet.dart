import 'package:flutter/material.dart';

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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ${l10n.titleAndClose}
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
            Divider(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.12),
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
