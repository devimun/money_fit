/// Stable values persisted to the contact-inquiry backend.
///
/// Presentation code maps these values to localized labels. Never use a label
/// as a backend value: labels change with locale and copy edits.
enum ContactInquiryType {
  bugReport('bug_report'),
  featureSuggestion('feature_suggestion'),
  generalInquiry('general_inquiry'),
  other('other');

  const ContactInquiryType(this.backendCode);

  final String backendCode;
}
