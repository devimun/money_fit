import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
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

  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late List<int> years;
  late List<int> months;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;

    years = <int>[2023, 2024, 2025, 2026, 2027];
    months = List.generate(12, (index) => index + 1);

    _yearController = FixedExtentScrollController(
      initialItem: years.indexOf(selectedYear),
    );
    _monthController = FixedExtentScrollController(
      initialItem: months.indexOf(selectedMonth),
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  /// 로케일에 맞는 월 이름 반환
  String _getLocalizedMonthName(BuildContext context, int month) {
    final locale = Localizations.localeOf(context).toString();
    final date = DateTime(2024, month, 1);
    return DateFormat.MMM(locale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.selectDate,
        textAlign: TextAlign.center,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        height: 150,
        width: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: context.colors.brandPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _yearController,
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedYear = years[index];
                      });
                    },
                    physics: const FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: years
                          .map(
                            (year) => Center(
                              child: Text(
                                l10n.yearLabel(year),
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: year == selectedYear
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: year == selectedYear
                                      ? context.colors.brandPrimary
                                      : context.colors.textPrimary.withValues(
                                          alpha: 0.6,
                                        ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller: _monthController,
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedMonth = months[index];
                      });
                    },
                    physics: const FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: months
                          .map(
                            (month) => Center(
                              child: Text(
                                _getLocalizedMonthName(context, month),
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: month == selectedMonth
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: month == selectedMonth
                                      ? context.colors.brandPrimary
                                      : context.colors.textPrimary.withValues(
                                          alpha: 0.6,
                                        ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.only(bottom: 16.0),
      actions: [
        Padding(
          padding: EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.brandPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, DateTime(selectedYear, selectedMonth));
            },
            child: Text(
              l10n.confirm,
              style: TextStyle(color: context.colors.textOnBrand),
            ),
          ),
        ),
      ],
    );
  }
}
