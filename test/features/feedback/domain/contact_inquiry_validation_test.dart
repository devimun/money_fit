import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/feedback/domain/contact_inquiry_validation.dart';

void main() {
  test('uses the same trimmed limits for optional email and details', () {
    expect(
      FeedbackContactInquiryValidation.hasValidOptionalEmail(
        '  person@example.com  ',
      ),
      isTrue,
    );
    expect(
      FeedbackContactInquiryValidation.hasValidOptionalEmail('not an email'),
      isFalse,
    );
    expect(
      FeedbackContactInquiryValidation.hasValidOptionalEmail(
        '${List.filled(250, 'a').join()}@example.com',
      ),
      isFalse,
    );
    expect(FeedbackContactInquiryValidation.hasValidDetails('   '), isFalse);
    expect(
      FeedbackContactInquiryValidation.hasValidDetails('A useful detail.'),
      isTrue,
    );
    expect(
      FeedbackContactInquiryValidation.hasValidDetails(
        List.filled(501, 'x').join(),
      ),
      isFalse,
    );
  });
}
