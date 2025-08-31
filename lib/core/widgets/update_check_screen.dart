import 'package:flutter/material.dart';
import 'package:money_fit/core/services/update_service.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class UpdateCheckScreen extends StatefulWidget {
  const UpdateCheckScreen({super.key});

  @override
  State<UpdateCheckScreen> createState() => _UpdateCheckScreenState();
}

class _UpdateCheckScreenState extends State<UpdateCheckScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final status = await UpdateService.fetchUpdateStatus();
    if (!mounted) return;
    if (status.isForceUpdateRequired) {
      final l10n = AppLocalizations.of(context)!;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(l10n.updateRequiredTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.updateRequiredBody),
              if (status.changelogLines.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.updateChangelogTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...status.changelogLines.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(e)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await UpdateService.openStorePage(null);
              },
              child: Text(l10n.updateButton),
            ),
          ],
        ),
      );
      // 강제 업데이트는 이 화면에서 머뭅니다. (스토어로 이동 유도)
      return;
    }

    if (status.isUpdateRecommended) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.updateAvailableBody),
          action: SnackBarAction(
            label: l10n.updateDetails,
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                builder: (_) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.updateSheetTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.updateAvailableBody),
                        const SizedBox(height: 12),
                        Text(
                          l10n.updateChangelogTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...status.changelogLines.map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(child: Text(e)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async =>
                                UpdateService.openStorePage(null),
                            child: Text(l10n.updateButtonGo),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // 체크 통과 시 스플래시로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go('/');
      }
    });
    return const Scaffold();
  }
}
