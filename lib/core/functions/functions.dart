import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/models/user_model.dart';
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
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondaryContainer,
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
  final locale = Localizations.localeOf(context).toString();
  final l10n = AppLocalizations.of(context)!;
  final currencySymbol = l10n.currency;
  if (value == value.roundToDouble()) {
    // 정수면 소수점 없이 포맷
    final intFormat = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: 0,
    );
    return '$currencySymbol${intFormat.format(value)}';
  } else {
    // 소수점 있을 땐 2자리까지 표시
    final decimalFormat = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: 2,
    );
    return '$currencySymbol${decimalFormat.format(value)}';
  }
}

/// 사용자의 예산 설정(일간/월간)과 국가에 따라 일일 예산을 계산합니다.
///
/// [user] - 예산 정보를 포함한 사용자 객체
/// [forDate] - 기준이 되는 날짜 (월간 예산 계산 시 필요)
double calculateDailyBudget(
  BudgetType budgetType,
  double budget,
  DateTime forDate,
) {
  if (budgetType == BudgetType.daily) {
    return budget;
  } else {
    // 월간 예산인 경우, 해당 월의 일수로 나누어 일일 예산을 계산합니다.
    final daysInMonth = DateTime(forDate.year, forDate.month + 1, 0).day;
    final rawDailyBudget = budget / daysInMonth;

    // 국가별 통화에 따라 소수점 처리를 다르게 합니다.
    final countryCode = Platform.localeName.split('_').last;
    if (countryCode == 'KR' || countryCode == 'ID') {
      // 한국 원, 인도네시아 루피아는 소수점을 사용하지 않습니다.
      return rawDailyBudget.floorToDouble();
    } else {
      // 그 외 국가는 소수점 둘째 자리까지 표시합니다. (달러, 링깃 등)
      return (rawDailyBudget * 100).roundToDouble() / 100;
    }
  }
}
