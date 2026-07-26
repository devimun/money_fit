import 'package:money_fit/core/platform/external_link_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherAdapter implements ExternalLinkLauncher {
  const UrlLauncherAdapter();

  @override
  Future<bool> launch(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
