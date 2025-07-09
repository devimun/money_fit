import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String numberFormatting(double number) {
  return NumberFormat('#,###').format(number);
}

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
