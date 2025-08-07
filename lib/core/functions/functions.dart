import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:money_fit/core/models/expense_model.dart';

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

DateTime normalizedDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String numberFormatting(BuildContext context, double number) {
  final locale = Localizations.localeOf(context).toString();
  final isKorean = locale.startsWith('ko');

  final formatter = NumberFormat.currency(
    locale: locale,
    symbol: isKorean ? '₩' : null, // null이면 로케일 기본값 사용
  );
  return formatter.format(number);
}

String dateFormatting(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  final formatter = DateFormat(
    AppLocalizations.of(context)!.dateFormat,
    locale,
  );
  return formatter.format(date);
}
