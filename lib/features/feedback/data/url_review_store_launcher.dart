import 'dart:io';

import 'package:money_fit/features/feedback/application/review_prompt_dependencies.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlReviewStoreLauncher implements ReviewStoreLauncher {
  const UrlReviewStoreLauncher();

  @override
  Future<void> launch() async {
    const androidAppId = 'com.moneyfitapp.app';
    const iOSAppId = '6749416452';
    final Uri? storeUrl = Platform.isAndroid
        ? Uri.parse('market://details?id=$androidAppId')
        : Platform.isIOS
        ? Uri.parse(
            'https://apps.apple.com/app/id$iOSAppId?action=write-review',
          )
        : null;
    if (storeUrl == null) return;

    if (await canLaunchUrl(storeUrl)) {
      await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
      return;
    }
    if (Platform.isAndroid) {
      final webUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=$androidAppId',
      );
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }
  }
}
