/// Shared normalized validation for the contact UI and remote repository.
abstract final class FeedbackContactInquiryValidation {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool hasValidOptionalEmail(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ||
        (normalized.length <= 254 && _emailPattern.hasMatch(normalized));
  }

  static bool hasValidDetails(String value) {
    final normalized = value.trim();
    return normalized.isNotEmpty && normalized.length <= 500;
  }
}
