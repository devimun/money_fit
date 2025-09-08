/// 지출 폼 검증을 담당하는 클래스
class ExpenseFormValidator {
  /// 폼 유효성 검사
  static bool validateForm({
    required String name,
    required String rawAmount,
    required String? selectedCategoryId,
  }) {
    if (name.trim().isEmpty) return false;
    if (rawAmount.trim().isEmpty) return false;
    
    final amount = double.tryParse(rawAmount.trim().replaceAll(',', ''));
    if (amount == null || amount <= 0) return false;
    if (selectedCategoryId == null) return false;
    
    return true;
  }

  /// 에러 메시지 생성
  static String? getErrorMessage({
    required String name,
    required String rawAmount,
    required String? selectedCategoryId,
  }) {
    if (name.trim().isEmpty) return 'Name is empty';
    if (rawAmount.trim().isEmpty) return 'Amount is empty';
    
    final amount = double.tryParse(rawAmount.trim().replaceAll(',', ''));
    if (amount == null || amount <= 0) return 'Amount is invalid';
    if (selectedCategoryId == null) return 'Category is not selected';
    
    return null;
  }
}
