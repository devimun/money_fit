import 'package:money_fit/core/platform/analytics_event.dart';

/// Applies the canonical tracking-plan allowlist before either analytics SDK
/// sees an event. New properties are intentionally dropped until reviewed.
class AnalyticsSanitizer {
  static const forbiddenKeys = {
    'name',
    'amount',
    'email',
    'details',
    'detail',
    'uid',
    'user_id',
    'category_id',
    'transaction_name',
    'feedback',
    'body',
    'text',
    'id',
    'client_submission_id',
    'route',
    'path',
    'url',
  };

  static const categoryKeys = {
    'food',
    'traffic',
    'communication',
    'housing',
    'medical',
    'insurance',
    'necessities',
    'finance',
    'eating-out',
    'cafe',
    'shopping',
    'hobby',
    'travel',
    'subscribe',
    'beauty',
  };

  static const _allowedByEvent = <AnalyticsEvent, Set<String>>{
    AnalyticsEvent.screenViewed: {
      'screen_name',
      'previous_screen_name',
      'navigation_type',
    },
    AnalyticsEvent.transactionCreated: {
      'transaction_type',
      'category_key',
      'is_custom_category',
      'entry_point',
    },
    AnalyticsEvent.transactionUpdated: {
      'transaction_type',
      'category_key',
      'is_custom_category',
      'entry_point',
      'changed_fields',
    },
    AnalyticsEvent.transactionDeleted: {
      'transaction_type',
      'category_key',
      'is_custom_category',
      'source_screen',
    },
    AnalyticsEvent.budgetSet: {
      'is_initial',
      'budget_period',
      'previous_budget_period',
    },
    AnalyticsEvent.dataReset: {'scope'},
    AnalyticsEvent.inquirySubmitted: {'inquiry_type', 'result'},
    AnalyticsEvent.feedbackPromptOpportunity: {
      'variant',
      'eligible',
      'suppress_reason',
      'policy_version',
      'trigger',
    },
    AnalyticsEvent.feedbackPromptShown: {
      'variant',
      'policy_version',
      'install_age_bucket',
      'action_count_bucket',
      'session_count_bucket',
    },
    AnalyticsEvent.feedbackPromptResponded: {
      'action',
      'policy_version',
      'visible_duration_bucket',
    },
    AnalyticsEvent.feedbackSubmitted: {
      'source',
      'length_bucket',
      'attempt_count_bucket',
    },
    AnalyticsEvent.feedbackSubmissionFailed: {
      'source',
      'error_category',
      'attempt_count_bucket',
    },
    AnalyticsEvent.adActionRecorded: {
      'trigger',
      'screen',
      'action_count',
      'ad_policy_version',
    },
    AnalyticsEvent.adOpportunity: {
      'opportunity',
      'eligible',
      'suppress_reason',
      'ad_policy_version',
    },
    AnalyticsEvent.adRequest: {'ad_format', 'placement', 'platform'},
    AnalyticsEvent.adLoadCompleted: {
      'ad_format',
      'placement',
      'result',
      'latency_ms',
      'error_code',
      'error_domain',
    },
    AnalyticsEvent.adDisplayed: {
      'ad_format',
      'placement',
      'trigger',
      'ad_policy_version',
    },
    AnalyticsEvent.adImpression: {
      'ad_format',
      'placement',
      'ad_policy_version',
    },
    AnalyticsEvent.adClicked: {'ad_format', 'placement'},
    AnalyticsEvent.adDismissed: {
      'ad_format',
      'placement',
      'visible_duration_ms',
    },
    AnalyticsEvent.adDisplayFailed: {'ad_format', 'placement', 'error_code'},
    AnalyticsEvent.adRevenueTracked: {
      'ad_format',
      'placement',
      'value_micros',
      'currency_code',
      'precision',
    },
    AnalyticsEvent.adConfigInvalid: {
      'key',
      'value_source',
      'ad_policy_version',
    },
    AnalyticsEvent.expenseFilterApplied: {
      'has_type_filter',
      'has_category_filter',
      'category_key',
      'sort_order',
      'month_offset_bucket',
    },
    AnalyticsEvent.statisticsViewChanged: {
      'control',
      'transaction_type',
      'month_offset_bucket',
    },
    AnalyticsEvent.calendarPeriodChanged: {'method', 'month_offset_bucket'},
    AnalyticsEvent.notificationPreferenceChanged: {
      'enabled',
      'permission_result',
    },
    AnalyticsEvent.languageChanged: {
      'from_language',
      'to_language',
      'currency_code',
    },
  };

  static const _routeNames = {
    'update_check',
    'splash',
    'budget_setup',
    'home',
    'calendar',
    'statistics',
    'expense_list',
    'settings',
  };

  static const _knownStringValues = <String, Set<String>>{
    'transaction_type': {'essential', 'discretionary'},
    'budget_period': {'daily', 'monthly'},
    'previous_budget_period': {'daily', 'monthly'},
    'inquiry_type': {
      'bug_report',
      'feature_suggestion',
      'general_inquiry',
      'other',
    },
    'result': {'success', 'failure'},
    'source': {'review_negative', 'proactive_prompt'},
    'ad_format': {'banner', 'interstitial'},
    'placement': {
      'natural_break',
      'home',
      'calendar',
      'settings',
      'stats',
      'expenses',
    },
    'scope': {'local_database'},
    'permission_result': {
      'granted',
      'denied',
      'permanently_denied',
      'not_required',
    },
    'navigation_type': {'push', 'replace', 'pop', 'branch_switch'},
    'entry_point': {'home', 'calendar', 'expense_list'},
  };

  static const _boundedNumbers = <String, int>{
    'action_count': 1000,
    'latency_ms': 120000,
    'visible_duration_ms': 3600000,
    'value_micros': 100000000000,
  };

  Map<String, Object> sanitize(
    AnalyticsEvent event,
    Map<String, Object?> values, {
    String analyticsEnvironment = 'dev',
  }) {
    final result = <String, Object>{
      'schema_version': analyticsSchemaVersion,
      'analytics_env': analyticsEnvironment == 'prod' ? 'prod' : 'dev',
    };
    final allowed = _allowedByEvent[event] ?? const <String>{};
    values.forEach((key, value) {
      if (!allowed.contains(key) ||
          forbiddenKeys.contains(key) ||
          value == null) {
        return;
      }
      final sanitized = _sanitizeProperty(key, value);
      if (sanitized != null) result[key] = sanitized;
    });
    return result;
  }

  Object? _sanitizeProperty(String key, Object value) {
    if (key == 'policy_version' || key == 'ad_policy_version') {
      return value is String &&
              RegExp(r'^[A-Za-z0-9_.-]{1,80}$').hasMatch(value) &&
              !_looksLikeUuid(value)
          ? value
          : null;
    }
    if (key == 'category_key') {
      return value is String
          ? (categoryKeys.contains(value) ? value : 'custom')
          : null;
    }
    if (key == 'screen_name' ||
        key == 'previous_screen_name' ||
        key == 'source_screen' ||
        key == 'screen') {
      return value is String && _routeNames.contains(value) ? value : null;
    }
    if (key == 'changed_fields') {
      if (value is! List) {
        return null;
      }
      const fields = {'type', 'category', 'date', 'amount', 'name'};
      final result =
          value.whereType<String>().where(fields.contains).toSet().toList()
            ..sort();
      return result.isEmpty ? null : result;
    }
    final known = _knownStringValues[key];
    if (known != null) {
      return value is String && known.contains(value) ? value : null;
    }
    final maximum = _boundedNumbers[key];
    if (maximum != null) {
      if (value is! num ||
          value.isNaN ||
          value.isInfinite ||
          value < 0 ||
          value > maximum) {
        return null;
      }
      return value;
    }
    if (value is bool) return value;
    if (value is String && value.length <= 64 && !_looksLikeUuid(value)) {
      return value;
    }
    return null;
  }

  bool _looksLikeUuid(String value) => RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  ).hasMatch(value);
}
