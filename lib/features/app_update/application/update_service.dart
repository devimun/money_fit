import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateStatus {
  final bool isForceUpdateRequired;
  final bool isUpdateRecommended;
  final String messageToDisplay;
  final Uri? storeUri;
  final List<String> changelogLines;
  final RemoteCapabilityUnavailable? remoteCapabilityUnavailable;
  final Object? remoteCheckError;
  final StackTrace? remoteCheckStackTrace;

  const UpdateStatus({
    required this.isForceUpdateRequired,
    required this.isUpdateRecommended,
    required this.messageToDisplay,
    required this.storeUri,
    required this.changelogLines,
    this.remoteCapabilityUnavailable,
    this.remoteCheckError,
    this.remoteCheckStackTrace,
  });

  static const none = UpdateStatus(
    isForceUpdateRequired: false,
    isUpdateRecommended: false,
    messageToDisplay: '',
    storeUri: null,
    changelogLines: [],
  );

  factory UpdateStatus.remoteUnavailable(
    RemoteCapabilityUnavailable unavailable,
  ) {
    return UpdateStatus(
      isForceUpdateRequired: false,
      isUpdateRecommended: false,
      messageToDisplay: '',
      storeUri: null,
      changelogLines: const [],
      remoteCapabilityUnavailable: unavailable,
    );
  }

  bool get isRemoteCheckUnavailable => remoteCapabilityUnavailable != null;

  bool get hasRemoteCheckError => remoteCheckError != null;
}

class UpdateService {
  static const String rcKeyLatestVersion = 'latest_version';
  static const String rcKeyMinSupportedVersion = 'min_supported_version';
  static const String rcKeyUpdateChangelog = 'update_changelog';

  static Future<UpdateStatus> fetchUpdateStatus({
    AppEnvironment? environment,
    FirebaseRemoteConfig? remoteConfig,
  }) async {
    final activeEnvironment = environment ?? AppEnvironment.fromDartDefines();
    if (!activeEnvironment.firebase.isAvailable) {
      return UpdateStatus.remoteUnavailable(
        activeEnvironment.firebase.unavailable!,
      );
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    log('currentVersion: $currentVersion');

    final config =
        remoteConfig ??
        (throw StateError(
          'An update source must be supplied by app composition.',
        ));
    await config.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 30),
      ),
    );
    await config.setDefaults(<String, dynamic>{
      rcKeyLatestVersion: currentVersion,
      rcKeyMinSupportedVersion: '',
      rcKeyUpdateChangelog: '',
    });

    Object? remoteCheckError;
    StackTrace? remoteCheckStackTrace;
    try {
      await config.fetchAndActivate();
    } catch (error, stackTrace) {
      // Cached/default values can still produce a valid update decision, but
      // callers must be able to distinguish that from a successful refresh.
      remoteCheckError = error;
      remoteCheckStackTrace = stackTrace;
    }

    final latest = config.getString(rcKeyLatestVersion).trim();
    log('latest: $latest');
    final minSupported = config.getString(rcKeyMinSupportedVersion).trim();
    log('minSupported: $minSupported');
    // 메시지는 l10n에서 처리하고, Remote Config는 변경 내역만 관리
    final String message = '';
    String changelogRaw = config.getString(rcKeyUpdateChangelog).trim();
    List<String> changelogLines;
    if (changelogRaw.startsWith('{')) {
      try {
        final decoded = json.decode(changelogRaw);
        if (decoded is Map) {
          final ui.Locale locale = ui.PlatformDispatcher.instance.locale;
          final String lang = locale.languageCode.toLowerCase();
          dynamic selected = decoded[lang];
          selected ??= decoded['en'];
          if (selected is List) {
            changelogLines = selected
                .whereType<dynamic>()
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList(growable: false);
          } else if (selected is String) {
            changelogLines = _parseChangelog(selected);
          } else {
            changelogLines = const <String>[];
          }
        } else {
          changelogLines = _parseChangelog(changelogRaw);
        }
      } catch (_) {
        changelogLines = _parseChangelog(changelogRaw);
      }
    } else {
      changelogLines = _parseChangelog(changelogRaw);
    }

    final bool mustUpdate =
        minSupported.isNotEmpty &&
        _compareSemver(currentVersion, minSupported) < 0;
    final bool shouldUpdate =
        !mustUpdate &&
        latest.isNotEmpty &&
        _compareSemver(currentVersion, latest) < 0;

    if (!mustUpdate && !shouldUpdate) {
      if (remoteCheckError == null) return UpdateStatus.none;
      return UpdateStatus(
        isForceUpdateRequired: false,
        isUpdateRecommended: false,
        messageToDisplay: '',
        storeUri: null,
        changelogLines: const [],
        remoteCheckError: remoteCheckError,
        remoteCheckStackTrace: remoteCheckStackTrace,
      );
    }

    return UpdateStatus(
      isForceUpdateRequired: mustUpdate,
      isUpdateRecommended: shouldUpdate,
      messageToDisplay: message,
      storeUri: null,
      changelogLines: changelogLines,
      remoteCheckError: remoteCheckError,
      remoteCheckStackTrace: remoteCheckStackTrace,
    );
  }

  static Future<void> openStorePage(
    Uri? uri, {
    AppEnvironment? environment,
  }) async {
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    // 플랫폼별 기본 링크 생성
    if (Platform.isAndroid) {
      final info = await PackageInfo.fromPlatform();
      final packageName = info.packageName;
      final market = Uri.parse('market://details?id=$packageName');
      if (await canLaunchUrl(market)) {
        await launchUrl(market, mode: LaunchMode.externalApplication);
        return;
      }
      final web = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName',
      );
      await launchUrl(web, mode: LaunchMode.externalApplication);
    } else if (Platform.isIOS) {
      final appId =
          environment?.iosAppId ?? AppEnvironment.fromDartDefines().iosAppId;
      if (appId != null && appId.isNotEmpty) {
        final appStore = Uri.parse('https://apps.apple.com/app/id$appId');
        if (await canLaunchUrl(appStore)) {
          await launchUrl(appStore, mode: LaunchMode.externalApplication);
          return;
        }
      }
      // 폴백: 앱스토어 검색 페이지(최후)
      final web = Uri.parse('https://apps.apple.com');
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  static int _compareSemver(String a, String b) {
    List<int> parse(String v) =>
        v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final av = parse(a);
    final bv = parse(b);
    final len = av.length > bv.length ? av.length : bv.length;
    for (int i = 0; i < len; i++) {
      final ai = i < av.length ? av[i] : 0;
      final bi = i < bv.length ? bv[i] : 0;
      if (ai != bi) return ai.compareTo(bi);
    }
    return 0;
  }

  // Remote Config 기반 URL을 사용하지 않도록 단순화

  static List<String> _parseChangelog(String raw) {
    if (raw.isEmpty) return const [];
    final trimmed = raw.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      try {
        final decoded = json.decode(trimmed);
        if (decoded is List) {
          return decoded
              .whereType<dynamic>()
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList(growable: false);
        }
      } catch (_) {}
    }
    final lines = trimmed.split(RegExp(r'\r?\n'));
    return lines
        .map((e) => e.replaceFirst(RegExp(r'^[-•]\s*'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }
}
