import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/widgets/ads/ad_banner_widget.dart';
import 'package:money_fit/features/calendar/view/widgets/helper.dart';
import 'package:money_fit/features/calendar/viewmodel/calendar_view_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = ref.watch(calendarViewModel);
    return viewModel.when(
      data: (data) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        body: Column(
          children: [
            const AdBannerWidget(screenType: ScreenType.calendar),
            Expanded(
              child: SingleChildScrollView(
                child: TableCalendar(
                  availableGestures: AvailableGestures.none,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    rightChevronVisible: false,
                    leftChevronVisible: false,
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    tablePadding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                  ),
                  daysOfWeekHeight: 40,
                  rowHeight: MediaQuery.sizeOf(context).height * 0.09,
                  focusedDay: data.selectedDay,
                  selectedDayPredicate: (day) =>
                      normalizedDate(day) == data.selectedDay,
                  firstDay: DateTime(2025, 07, 01),
                  lastDay: DateTime(2030, 12, 31),
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (context, day) => buildCalendarHeader(
                      ref,
                      data.calendarStat,
                      day,
                      context,
                    ),
                    dowBuilder: (context, day) {
                      final koreanWeekdays = [
                        l10n.sunday,
                        l10n.monday,
                        l10n.tuesday,
                        l10n.wednesday,
                        l10n.thursday,
                        l10n.friday,
                        l10n.saturday,
                      ];
                      final weekdayIndex = day.weekday % 7;
                      final label = koreanWeekdays[weekdayIndex];

                      Color? color;
                      if (day.weekday == DateTime.sunday) {
                        color = Colors.red;
                      } else if (day.weekday == DateTime.saturday) {
                        color = Colors.blue;
                      } else {
                        color = Theme.of(context).colorScheme.onSurface;
                      }

                      return Align(
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(color: color),
                        ),
                      );
                    },
                    disabledBuilder: (context, day, focusedDay) {
                      return const SizedBox.shrink();
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      return const SizedBox.shrink();
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      final date = normalizedDate(day);
                      return buildCalendarCell(
                        data.calendarCells[date],
                        date,
                        context,
                        ref,
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      final date = normalizedDate(day);

                      return buildCalendarCell(
                        data.calendarCells[date],
                        date,
                        context,
                        ref,
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      final date = normalizedDate(day);

                      return buildCalendarCell(
                        data.calendarCells[date],
                        date,
                        context,
                        ref,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      loading: () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator(), Text(l10n.pleaseWait)],
      ),
      error: (error, stackTrace) =>
          Center(child: Text(l10n.errorOccurred(error.toString()))),
    );
  }
}
