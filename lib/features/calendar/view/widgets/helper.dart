import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/calendar/model/model.dart';
import 'package:money_fit/features/calendar/view/widgets/calendar_cell.dart';
import 'package:money_fit/features/calendar/view/widgets/calendar_header.dart';

/// 캘린더 셀을 생성하는 팩토리 함수
Widget buildCalendarCell(
  CalendarCellData? cellData,
  DateTime day,
  BuildContext context,
  WidgetRef ref,
) {
  return CalendarCell(cellData: cellData, day: day);
}

/// 캘린더 헤더를 생성하는 팩토리 함수
Widget buildCalendarHeader(
  WidgetRef ref,
  CalendarStat stat,
  DateTime day,
  BuildContext context,
) {
  return CalendarHeader(stat: stat, day: day);
}