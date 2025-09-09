// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '머니핏';

  @override
  String get onboardingTitle1 => '복잡한 가계부는 이제 그만';

  @override
  String get onboardingDescription1 => '매일의 지출을 간편하게 관리하고,\n건강한 소비 습관을 만들어보세요.';

  @override
  String get onboardingTitle2 => '한 눈에 확인 가능한 하루 예산';

  @override
  String get onboardingDescription2 => '오늘 남은 예산을 파악하고,\n계획적인 소비를 시작하세요.';

  @override
  String get onboardingTitle3 => '성취의 기록이 꾸준한 습관으로';

  @override
  String get onboardingDescription3 => '매일의 도전을 성취로 채우고,\n돈 관리의 재미를 느껴보세요.';

  @override
  String get next => '다음으로';

  @override
  String get dailyBudgetSetupTitle => '예산 설정하기';

  @override
  String get budgetSetupDescription =>
      '자율 지출 예산을 설정해주세요.\n자유 지출이란, 공과금,의료비,주거비,보험 등 필수 지출을 제외한 자유롭게 사용할 수 있는 금액을 말해요.';

  @override
  String get dailyBudgetLabel => '일일 예산 (원)';

  @override
  String get monthlyBudgetLabel => '월간 예산 (원)';

  @override
  String get enterBudgetPrompt => '예산을 입력해주세요.';

  @override
  String get enterValidNumberPrompt => '유효한 숫자를 입력해주세요.';

  @override
  String get budgetGreaterThanZeroPrompt => '예산은 0보다 커야 합니다.';

  @override
  String get start => '시작하기';

  @override
  String errorOccurred(Object error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get dateFormat => 'yyyy.MM.dd EEEE';

  @override
  String get dailyDiscretionarySpending => '일일 자율 지출 : ';

  @override
  String get monthlyDiscretionarySpending2 => '월간 자율 지출 : ';

  @override
  String get dailyBudget => '일일 자율 지출 예산 : ';

  @override
  String get monthlyBudget => '월간 자율 지출 예산 : ';

  @override
  String get monthlyAvgDiscSpending => '월평균 일일 자율 지출';

  @override
  String get consecutiveDays => '연속 목표 달성일';

  @override
  String days(Object count) {
    return '$count일';
  }

  @override
  String get currency => '₩';

  @override
  String get viewTodaySpending => '오늘 지출 보기';

  @override
  String totalSpendingCount(num count) {
    return '총 $count건의 지출이 있어요';
  }

  @override
  String get addExpense => '지출 등록';

  @override
  String get addNewExpensePrompt => '새로운 지출을 등록해 주세요';

  @override
  String get notificationDialogTitle => '지출 기록을 잊지 않게 도와드려요';

  @override
  String get notificationDialogDescription =>
      '지출 기록 , 어렵진 않지만 잊어버리기 쉽죠.\n잊지 않도록 매일 알림으로 도와드릴게요. \n알림을 받아 보시겠어요?';

  @override
  String get notificationDialogDeny => '괜찮아요';

  @override
  String get notificationDialogConfirm => '네, 좋아요';

  @override
  String get category_food => '식사';

  @override
  String get category_traffic => '교통';

  @override
  String get category_insurance => '보험';

  @override
  String get category_necessities => '생필품';

  @override
  String get category_communication => '통신';

  @override
  String get category_housing => '주거/공과금';

  @override
  String get category_medical => '의료';

  @override
  String get category_finance => '금융';

  @override
  String get categoryEatingOut => '외식';

  @override
  String get category_cafe => '카페/간식';

  @override
  String get category_shopping => '쇼핑';

  @override
  String get category_hobby => '취미/여가';

  @override
  String get category_travel => '여행/휴식';

  @override
  String get category_subscribe => '구독';

  @override
  String get category_beauty => '미용';

  @override
  String get expenseType_essential => '필수 지출';

  @override
  String get expenseType_discretionary => '자율 지출';

  @override
  String get dailyExpenseHistory => '일일 지출 내역';

  @override
  String get noExpenseHistory => '지출 내역이 존재하지 않습니다.';

  @override
  String get editDeleteExpense => '지출 수정/삭제';

  @override
  String editDeleteExpensePrompt(Object expenseName) {
    return '지출 \"$expenseName\"에 대해 어떤 작업을 하시겠습니까?';
  }

  @override
  String get edit => '수정';

  @override
  String get delete => '삭제';

  @override
  String get allExpenses => '모든 지출';

  @override
  String get allCategories => '모든 카테고리';

  @override
  String get unknown => '알 수 없음';

  @override
  String get ascending => '오름차순';

  @override
  String get descending => '내림차순';

  @override
  String get noExpenseData => '지출 내역이 존재하지 않습니다';

  @override
  String get changeFilterPrompt => '필터 조건을 변경하거나\n새로운 지출을 추가해보세요';

  @override
  String get allFieldsRequired => '모든 항목을 올바르게 입력해주세요.';

  @override
  String get addNewCategory => '새 카테고리 추가';

  @override
  String get cancel => '취소';

  @override
  String get add => '추가';

  @override
  String get deleteCategory => '카테고리 삭제';

  @override
  String deleteCategoryPrompt(Object categoryName) {
    return '\'$categoryName\' 카테고리를 삭제하시겠습니까?';
  }

  @override
  String get pleaseWait => '잠시만 기다려 주세요...';

  @override
  String get noDataExists => '데이터가 존재하지 않습니다.';

  @override
  String get reset => '초기화';

  @override
  String get selectDate => '날짜 선택';

  @override
  String yearLabel(Object year) {
    return '$year년';
  }

  @override
  String monthLabel(Object month) {
    return '$month월';
  }

  @override
  String get confirm => '확인';

  @override
  String get budgetSetting => '예산 설정';

  @override
  String get save => '저장';

  @override
  String get resetInformation => '정보 초기화';

  @override
  String get notificationPermissionRequired => '알림 권한 필요';

  @override
  String get notificationPermissionDescription =>
      '알림 기능을 사용하려면 설정에서 알림 권한을 허용해주세요.';

  @override
  String get goToSettings => '설정으로 이동';

  @override
  String get monthlyDiscretionarySpending => '월간 자율 지출';

  @override
  String get monthlyEssentialSpending => '월간 필수 지출';

  @override
  String get success => '성공';

  @override
  String get failure => '실패';

  @override
  String get consecutiveSuccess => '연속 성공';

  @override
  String daysCount(Object count) {
    return '$count일';
  }

  @override
  String yearMonth(Object month, Object year) {
    return '$year $month';
  }

  @override
  String get nameIsEmpty => '이름이 비어 있습니다.';

  @override
  String get invalidAmount => '금액이 올바르지 않거나 0 이하입니다.';

  @override
  String get categoryNotSelected => '카테고리를 선택하지 않았습니다.';

  @override
  String formValidationError(Object error) {
    return '폼 유효성 오류: $error';
  }

  @override
  String get registerExpense => '지출 등록';

  @override
  String get register => '등록하기';

  @override
  String get date => '날짜';

  @override
  String get expenseName => '지출명';

  @override
  String get enterExpenseName => '지출명을 입력해주세요';

  @override
  String get amount => '금액';

  @override
  String get enterExpenseAmount => '지출 금액을 입력해주세요';

  @override
  String get expenseType => '지출 유형';

  @override
  String get essentialExpense => '필수 지출';

  @override
  String get discretionaryExpense => '자율 지출';

  @override
  String get categoryName => '카테고리 이름';

  @override
  String get sunday => '일';

  @override
  String get monday => '월';

  @override
  String get tuesday => '화';

  @override
  String get wednesday => '수';

  @override
  String get thursday => '목';

  @override
  String get friday => '금';

  @override
  String get saturday => '토';

  @override
  String errorWithMessage(Object error) {
    return '오류: $error';
  }

  @override
  String get darkMode => '다크 모드';

  @override
  String get apply => '적용';

  @override
  String get dataManagement => '데이터 관리';

  @override
  String get resetDataConfirmation => '모든 데이터를 초기화하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

  @override
  String get notificationSetting => '알림 설정';

  @override
  String get category => '카테고리';

  @override
  String get selectExpenseTypeFirst => '지출 유형을 먼저 선택해주세요';

  @override
  String get errorLoadingCategories => '카테고리를 불러오는 중 오류 발생';

  @override
  String get queryMonth => '조회 월';

  @override
  String get remainingAmount => '남은 금액';

  @override
  String get todayExpenseMessageZero => '오늘의 지출을 등록해 주세요 😊';

  @override
  String get todayExpenseMessageGood => '좋아요! 오늘은 아직 여유 있어요 🌿';

  @override
  String get todayExpenseMessageHalf => '절반 가까이 사용했어요!\n이제 조금만 신경써볼까요? 🔔';

  @override
  String get todayExpenseMessageNearLimit => '조금만 더 쓰면 오늘 예산을 초과해요! ⚠️';

  @override
  String get todayExpenseMessageOverLimit => '오늘 예산을 초과했어요! 지출을 조절해봐요 ❗';

  @override
  String get information => '정보';

  @override
  String get writeReview => '리뷰 작성';

  @override
  String get appVersion => '앱 버전';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get basicSettings => '기본 설정';

  @override
  String get titleAndClose => '제목 & 닫기';

  @override
  String get filterSettings => '필터 설정';

  @override
  String get sort => '정렬';

  @override
  String get latest => '최신순';

  @override
  String get oldest => '오래된순';

  @override
  String get statistics => '통계';

  @override
  String get spendingByCategory => '카테고리별 지출 현황';

  @override
  String get top3ExpensesThisMonth => '이번 달 지출 TOP3';

  @override
  String get home => '홈';

  @override
  String get daily => '일일';

  @override
  String get monthly => '월간';

  @override
  String get calendar => '캘린더';

  @override
  String get stats => '통계';

  @override
  String get expense => '지출 내역';

  @override
  String get settings => '설정';

  @override
  String get notificationTitleDaily => '일일 지출 알림';

  @override
  String get notificationBodyMorning =>
      '좋은 아침이에요 ☀️ 오늘의 첫 지출을 등록해볼까요? 작은 습관이 큰 변화를 만들어요!';

  @override
  String get notificationBodyAfternoon =>
      '맛있는 점심 드셨나요? 🍱 이제 지출 내역을 간단히 정리해볼까요?';

  @override
  String get notificationBodyNight =>
      '하루가 벌써 지나갔네요 🌙 오늘의 지출을 차분히 정리하며 하루를 마무리해보세요.';

  @override
  String get resetComplete => '머니핏을 이용해주셔서 감사합니다.';

  @override
  String get upgraderTitle => '업데이트 알림';

  @override
  String get upgraderBody => '새로운 버전이 출시되었습니다. 더 나은 서비스를 위해 업데이트를 진행해주세요.';

  @override
  String get upgraderPrompt => '지금 바로 업데이트하시겠어요?';

  @override
  String get upgraderButtonLater => '나중에';

  @override
  String get upgraderButtonUpdate => '업데이트';

  @override
  String get upgraderButtonIgnore => '무시';

  @override
  String get updateRequiredTitle => '업데이트가 필요해요';

  @override
  String get updateRequiredBody => '원활한 사용을 위해 최신 버전으로 업데이트 해주세요.';

  @override
  String get updateAvailableBody => '새 버전이 있어요. 최신 기능과 개선사항을 만나보세요.';

  @override
  String get updateChangelogTitle => '변경 내역';

  @override
  String get updateButton => '업데이트';

  @override
  String get updateDetails => '자세히';

  @override
  String get updateSheetTitle => '업데이트 안내';

  @override
  String get updateButtonGo => '업데이트 하러 가기';

  @override
  String get review_modal_binary_title => '지금까지 앱 사용이 만족스러우셨나요?';

  @override
  String get review_modal_button_good => '좋았어요';

  @override
  String get review_modal_button_bad => '별로였어요';

  @override
  String get review_positive_title => '어떤 점이 좋으셨는지 알려주실 수 있을까요?';

  @override
  String get review_positive_button_yes => '좋아요';

  @override
  String get review_button_later => '다음에 하기';

  @override
  String get review_button_never => '다시 보지 않기';

  @override
  String get review_negative_title => '어떤 점이 불편했는지 말씀해주세요.';

  @override
  String get review_negative_hint => '불편했던 점을 작성해 주세요.';

  @override
  String get review_negative_button_send => '보내기';

  @override
  String get review_thanks_message => '알려주셔서 감사합니다. 개선에 반영할 수 있도록 하겠습니다.';

  @override
  String get monthlyExpenseMessageZero => '이번 달 아직 자율 지출이 없어요!';

  @override
  String get monthlyExpenseMessageGood => '이번 달 예산 관리가 잘 되고 있어요!';

  @override
  String get monthlyExpenseMessageHalf => '이번 달 절반 정도 사용했어요';

  @override
  String get monthlyExpenseMessageNearLimit => '이번 달 예산이 거의 소진되었어요';

  @override
  String get monthlyExpenseMessageOverLimit => '이번 달 예산을 초과했어요';

  @override
  String get contactUs => '문의하기';

  @override
  String get inquiryType => '문의 유형';

  @override
  String get inquiryTypeBugReport => '버그 신고';

  @override
  String get inquiryTypeFeatureSuggestion => '기능 제안';

  @override
  String get inquiryTypeGeneralInquiry => '일반 문의';

  @override
  String get inquiryTypeOther => '기타';

  @override
  String get replyEmail => '답변받을 이메일';

  @override
  String get inquiryDetails => '문의 내용';

  @override
  String get submit => '보내기';

  @override
  String get inquirySuccess => '문의가 성공적으로 제출되었습니다.';

  @override
  String get inquiryFailure => '문의 제출에 실패했습니다.';

  @override
  String get invalidEmail => '올바른 이메일 형식이 아닙니다.';

  @override
  String get fieldRequired => '필수 항목입니다.';
}
