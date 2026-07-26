/// Typed route locations and URL arguments owned by the app router.
///
/// GoRouter still receives URI strings at its boundary, but callers should not
/// assemble query strings themselves. This keeps query spelling and decoding
/// in one place while preserving deep-linkable URLs.
abstract final class AppRoutes {
  static const updateCheck = '/update-check';
  static const splash = '/';
  static const bootstrapFailure = '/bootstrap-failure';
  static const budgetSetup = '/budget_setup';
  static const homePath = '/home';
  static const calendar = '/calendar';
  static const statistics = '/stats';
  static const expenseList = '/expense_list';
  static const settings = '/settings';

  static String home([
    HomeRouteArguments arguments = const HomeRouteArguments(),
  ]) {
    return Uri(
      path: homePath,
      queryParameters: arguments.queryParameters,
    ).toString();
  }

  static String splashWith(BootstrapRouteArguments arguments) {
    return _withReturnTo(splash, arguments.returnTo);
  }

  static String withBootstrapReturnTo(
    String destination,
    AppRouteReturnTarget? returnTo,
  ) {
    return _withReturnTo(destination, returnTo);
  }

  static String _withReturnTo(
    String destination,
    AppRouteReturnTarget? returnTo,
  ) {
    if (returnTo == null) return destination;
    return Uri(
      path: destination,
      queryParameters: {'from': returnTo.location},
    ).toString();
  }
}

/// Arguments accepted by the home screen deep link.
class HomeRouteArguments {
  const HomeRouteArguments({this.showNotificationPrompt = false});

  factory HomeRouteArguments.fromUri(Uri uri) {
    return HomeRouteArguments(
      showNotificationPrompt:
          uri.queryParameters['showNotificationPrompt'] == 'true',
    );
  }

  final bool showNotificationPrompt;

  Map<String, String> get queryParameters => showNotificationPrompt
      ? const {'showNotificationPrompt': 'true'}
      : const {};
}

/// A local destination to restore after bootstrap has reached a terminal
/// screen. This is intentionally a value object instead of an arbitrary query
/// string so redirects cannot accidentally double-encode a location.
class AppRouteReturnTarget {
  const AppRouteReturnTarget._(this.location);

  factory AppRouteReturnTarget.fromUri(Uri uri) {
    return AppRouteReturnTarget._(uri.toString());
  }

  static AppRouteReturnTarget? tryParse(String? location) {
    if (location == null || location.isEmpty) return null;
    final uri = Uri.tryParse(location);
    if (uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        !uri.path.startsWith('/')) {
      return null;
    }
    return AppRouteReturnTarget._(uri.toString());
  }

  final String location;
}

/// Arguments common to bootstrap terminal screens.
class BootstrapRouteArguments {
  const BootstrapRouteArguments({this.returnTo});

  factory BootstrapRouteArguments.fromUri(Uri uri) {
    return BootstrapRouteArguments(
      returnTo: AppRouteReturnTarget.tryParse(uri.queryParameters['from']),
    );
  }

  final AppRouteReturnTarget? returnTo;
}
