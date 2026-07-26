class AnalyticsConfig {
  const AnalyticsConfig({
    required this.apiKey,
    required this.enabled,
    required this.environment,
    required this.serverZone,
  });

  factory AnalyticsConfig.fromEnvironment() {
    const key = String.fromEnvironment('AMPLITUDE_API_KEY');
    const enabled = bool.fromEnvironment(
      'AMPLITUDE_ENABLED',
      defaultValue: false,
    );
    const environment = String.fromEnvironment(
      'ANALYTICS_ENV',
      defaultValue: 'dev',
    );
    const zone = String.fromEnvironment(
      'AMPLITUDE_SERVER_ZONE',
      defaultValue: 'us',
    );
    return AnalyticsConfig(
      apiKey: key,
      enabled: enabled && key.isNotEmpty,
      environment: environment == 'prod' ? 'prod' : 'dev',
      serverZone: zone == 'eu' ? 'eu' : 'us',
    );
  }

  final String apiKey;
  final bool enabled;
  final String environment;
  final String serverZone;

  @override
  String toString() =>
      'AnalyticsConfig(enabled: $enabled, environment: $environment, serverZone: $serverZone)';
}
