import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/config/locale_config.dart';
import 'package:money_fit/core/models/user_model.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildCircleWidget(bool needPrimaryColor, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.03,
    height: MediaQuery.of(context).size.width * 0.03,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: needPrimaryColor
          ? context.colors.brandPrimary
          : context.colors.calendarCellBackground,
    ),
  );
}

// String getCategoryName(BuildContext context, String categoryId) {
//   final l10n = AppLocalizations.of(context)!;
//   switch (categoryId) {
//     case 'food':
//       return l10n.category_food;
//     case 'traffic':
//       return l10n.category_traffic;
//     case 'communication':
//       return l10n.category_communication;
//     case 'housing':
//       return l10n.category_housing;
//     case 'medical':
//       return l10n.category_medical;
//     case 'insurance':
//       return l10n.category_insurance;
//     case 'finance':
//       return l10n.category_finance;
//     case 'necessities':
//       return l10n.category_necessities;
//     case 'eating-out':
//       return l10n.categoryEatingOut;
//     case 'cafe':
//       return l10n.category_cafe;
//     case 'shopping':
//       return l10n.category_shopping;
//     case 'hobby':
//       return l10n.category_hobby;
//     case 'travel':
//       return l10n.category_travel;
//     case 'subscribe':
//       return l10n.category_subscribe;
//     case 'beauty':
//       return l10n.category_beauty;
//     default:
//       return l10n.unknown;
//   }
// }

String getExpenseTypeName(BuildContext context, ExpenseType type) {
  final l10n = AppLocalizations.of(context)!;
  switch (type) {
    case ExpenseType.essential:
      return l10n.expenseType_essential;
    case ExpenseType.discretionary:
      return l10n.expenseType_discretionary;
    default:
      return '';
  }
}

void launchReviewURL() async {
  const androidAppId = 'com.moneyfitapp.app'; // 예시 ID
  const iOSAppId = '6749416452';

  final Uri url;

  if (Platform.isAndroid) {
    url = Uri.parse('market://details?id=$androidAppId');
  } else if (Platform.isIOS) {
    url = Uri.parse(
      'https://apps.apple.com/app/id$iOSAppId?action=write-review',
    );
  } else {
    // 지원하지 않는 플랫폼
    return;
  }

  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // 스토어 앱을 직접 열 수 없을 경우 웹 URL로 시도
      final webUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=$androidAppId',
      );
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }
  } catch (e) {
    // 에러 처리 (예: 사용자에게 알림 표시)
  }
}

DateTime normalizedDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String dateFormatting(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  final formatter = DateFormat(
    AppLocalizations.of(context)!.dateFormat,
    locale,
  );
  return formatter.format(date);
}

String formatCurrencyAdaptive(BuildContext context, double value) {
  final locale = Localizations.localeOf(context);
  final localeConfig = getLocaleConfig(locale.languageCode);
  final currencySymbol = localeConfig.currencySymbol;
  final decimalDigits = localeConfig.decimalDigits;

  // 소수점 자릿수가 0인 통화(KRW, IDR)는 항상 정수로 표시
  if (decimalDigits == 0) {
    final intFormat = NumberFormat.currency(
      locale: locale.toString(),
      symbol: '',
      decimalDigits: 0,
    );
    return '$currencySymbol${intFormat.format(value)}';
  }

  // 소수점이 있는 통화는 값에 따라 동적으로 처리
  if (value == value.roundToDouble()) {
    // 정수면 소수점 없이 포맷
    final intFormat = NumberFormat.currency(
      locale: locale.toString(),
      symbol: '',
      decimalDigits: 0,
    );
    return '$currencySymbol${intFormat.format(value)}';
  } else {
    // 소수점 있을 땐 해당 통화의 소수점 자릿수까지 표시
    final decimalFormat = NumberFormat.currency(
      locale: locale.toString(),
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return '$currencySymbol${decimalFormat.format(value)}';
  }
}

/// 사용자의 예산 설정(일간/월간)과 통화에 따라 일일 예산을 계산합니다.
///
/// [budgetType] - 예산 유형 (일간/월간)
/// [budget] - 예산 금액
/// [forDate] - 기준이 되는 날짜 (월간 예산 계산 시 필요)
/// [decimalDigits] - 통화의 소수점 자릿수 (LocaleConfig에서 가져옴)
double calculateDailyBudget(
  BudgetType budgetType,
  double budget,
  DateTime forDate, {
  int decimalDigits = 2,
}) {
  if (budgetType == BudgetType.daily) {
    return budget;
  } else {
    // 월간 예산인 경우, 해당 월의 일수로 나누어 일일 예산을 계산합니다.
    final daysInMonth = DateTime(forDate.year, forDate.month + 1, 0).day;
    final rawDailyBudget = budget / daysInMonth;

    // 통화의 소수점 자릿수에 따라 처리
    if (decimalDigits == 0) {
      // 소수점 없는 통화 (KRW, IDR)
      return rawDailyBudget.floorToDouble();
    } else {
      // 소수점 있는 통화
      final multiplier = _pow10(decimalDigits);
      return (rawDailyBudget * multiplier).roundToDouble() / multiplier;
    }
  }
}

/// 10의 거듭제곱 계산 헬퍼 함수
double _pow10(int exponent) {
  double result = 1.0;
  for (int i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
