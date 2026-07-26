enum InquiryType { bugReport, featureSuggestion, generalInquiry, other }

extension InquiryTypeWire on InquiryType {
  String get wire => switch (this) {
    InquiryType.bugReport => 'bug_report',
    InquiryType.featureSuggestion => 'feature_suggestion',
    InquiryType.generalInquiry => 'general_inquiry',
    InquiryType.other => 'other',
  };
}
