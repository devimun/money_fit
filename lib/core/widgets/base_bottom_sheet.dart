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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 제목 & 닫기
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
            const SizedBox(height: 8),

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
