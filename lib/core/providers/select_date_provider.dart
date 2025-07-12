// 선택 날짜를 관리하는 프로바이더.
// 초기 객체 생성시에는 당일 날짜로 생성되며, 캘린더에서 날짜셀 선택시 해당 날짜로 변경된다.
// 또한 앱 라우팅 과정에서 홈으로 이동할 때는 당일로 변경되도록 한다.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/functions/functions.dart';

class DateManager extends Notifier<DateTime> {
  @override
  DateTime build() {
    final today = normalizedDate(DateTime.now());

    return today;
  }

  void changeDate(DateTime day) {
    state = normalizedDate(day);
  }
}

final dateManager = NotifierProvider<DateManager, DateTime>(
  () => DateManager(),
);
