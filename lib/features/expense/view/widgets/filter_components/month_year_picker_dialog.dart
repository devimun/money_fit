import 'package:flutter/material.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const MonthYearPickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.selectMonth),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(
                  widget.lastDate.year - widget.firstDate.year + 1,
                  (index) {
                    final year = widget.firstDate.year + index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(l10n.yearLabel(year)),
                    );
                  },
                ),
                onChanged: (year) {
                  if (year != null) {
                    setState(() {
                      selectedYear = year;
                    });
                  }
                },
              ),
              DropdownButton<int>(
                value: selectedMonth,
                items: List.generate(12, (index) {
                  final month = index + 1;
                  return DropdownMenuItem(
                    value: month,
                    child: Text(
                      l10n.monthLabel(month.toString().padLeft(2, '0')),
                    ),
                  );
                }),
                onChanged: (month) {
                  if (month != null) {
                    setState(() {
                      selectedMonth = month;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, DateTime(selectedYear, selectedMonth));
          },
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
