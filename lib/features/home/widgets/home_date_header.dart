import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeDateHeader extends StatelessWidget {
  const HomeDateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        DateFormat('yyyy.MM.dd EEEE', 'ko_KR').format(DateTime.now()),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}