import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_fit/features/expense/view/widgets/filter_components/month_year_picker_dialog.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class DateFilterSection extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateFilterSection({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    return _buildFormSection(
      label: l10n.queryMonth,
      child: InkWell(
        onTap: () => _showMonthYearPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onSecondary,
              width: 0.3,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.yearMonth(
                  DateFormat.MMM(locale).format(selectedDate),
                  DateFormat.y(locale).format(selectedDate),
                ),
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
      ),
      context: context,
    );
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => MonthYearPickerDialog(
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      ),
    );

    if (result != null) {
      onDateChanged(result);
    }
  }

  Widget _buildFormSection({
    required String label,
    required Widget child,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
