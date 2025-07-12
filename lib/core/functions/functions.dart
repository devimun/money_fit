import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

String numberFormatting(double number) {
  return NumberFormat('#,###').format(number);
}

String dateFormatting(DateTime dateTime) =>
    DateFormat('yyyy.MM.dd EEEE', 'ko_KR').format(dateTime);

DateTime normalizedDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
