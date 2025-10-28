// import 'package:flutter/material.dart';
// import 'package:money_fit/core/services/update_service.dart';
// import 'package:money_fit/l10n/app_localizations.dart';

// class UpdateGate extends StatefulWidget {
//   final Widget child;
//   final Duration recheckInterval;

//   const UpdateGate({
//     super.key,
//     required this.child,
//     this.recheckInterval = const Duration(hours: 6),
//   });

//   @override
//   State<UpdateGate> createState() => _UpdateGateState();
// }

// class _UpdateGateState extends State<UpdateGate> {
//   UpdateStatus _status = UpdateStatus.none;
//   DateTime _lastChecked = DateTime.fromMillisecondsSinceEpoch(0);
//   BuildContext? _childContext;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _maybeCheck();
//   }

//   Future<void> _maybeCheck() async {
//     if (DateTime.now().difference(_lastChecked) < widget.recheckInterval) {
//       return;
//     }
//     _lastChecked = DateTime.now();
//     final status = await UpdateService.fetchUpdateStatus();
//     if (!mounted) return;
//     setState(() => _status = status);
//     if (_status.isForceUpdateRequired) {
//       _showForceDialog();
//     } else if (_status.isUpdateRecommended) {
//       _showRecommendBanner();
//     }
//   }

//   BuildContext get _uiContext => _childContext ?? context;

//   void _showForceDialog() {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (!mounted) return;
//       final l10n = AppLocalizations.of(_uiContext)!;
//       await showDialog(
//         context: _uiContext,
//         barrierDismissible: false,
//         builder: (_) => AlertDialog(
//           title: Text(l10n.updateRequiredTitle),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _status.messageToDisplay.isEmpty
//                     ? l10n.updateRequiredBody
//                     : _status.messageToDisplay,
//               ),
//               if (_status.changelogLines.isNotEmpty) ...[
//                 const SizedBox(height: 12),
//                 Text(
//                   l10n.updateChangelogTitle,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 ..._status.changelogLines
//                     .take(6)
//                     .map((e) => _ChangeRow(text: e)),
//               ],
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 await UpdateService.openStorePage(_status.storeUri);
//               },
//               child: Text(l10n.updateButton),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   void _showRecommendBanner() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       final l10n = AppLocalizations.of(_uiContext)!;
//       final messenger = ScaffoldMessenger.of(_uiContext);
//       messenger.clearSnackBars();
//       messenger.showSnackBar(
//         SnackBar(
//           behavior: SnackBarBehavior.floating,
//           duration: const Duration(seconds: 10),
//           content: Text(
//             _status.messageToDisplay.isEmpty
//                 ? l10n.updateAvailableBody
//                 : _status.messageToDisplay,
//           ),
//           action: SnackBarAction(
//             label: _status.changelogLines.isNotEmpty
//                 ? l10n.updateDetails
//                 : l10n.updateButton,
//             onPressed: () async {
//               if (_status.changelogLines.isEmpty) {
//                 await UpdateService.openStorePage(_status.storeUri);
//                 return;
//               }
//               if (!mounted) return;
//               showModalBottomSheet(
//                 context: _uiContext,
//                 showDragHandle: true,
//                 isScrollControlled: true,
//                 builder: (_) {
//                   return SafeArea(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             l10n.updateSheetTitle,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           if (_status.messageToDisplay.isNotEmpty) ...[
//                             Text(_status.messageToDisplay),
//                             const SizedBox(height: 12),
//                           ],
//                           Text(
//                             l10n.updateChangelogTitle,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           ..._status.changelogLines.map(
//                             (e) => _ChangeRow(text: e),
//                           ),
//                           const SizedBox(height: 16),
//                           Align(
//                             alignment: Alignment.centerRight,
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 await UpdateService.openStorePage(
//                                   _status.storeUri,
//                                 );
//                               },
//                               child: Text(l10n.updateButtonGo),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Builder(
//       builder: (ctx) {
//         _childContext = ctx;
//         return widget.child;
//       },
//     );
//   }
// }

// class _ChangeRow extends StatelessWidget {
//   final String text;
//   const _ChangeRow({required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('• '),
//           Expanded(child: Text(text)),
//         ],
//       ),
//     );
//   }
// }
