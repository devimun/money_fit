import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';

/// Defers access to a remote feedback adapter until its optional capability is
/// ready. This lets local UI keep its draft and offer a retry while Supabase is
/// unconfigured, still initializing, or failed to initialize.
class CapabilityAwareFeedbackRepository implements FeedbackRepository {
  CapabilityAwareFeedbackRepository({
    required FeedbackRepository? Function() currentRepository,
    FeedbackRepository? unavailableRepository,
  }) : _currentRepository = currentRepository,
       _unavailableRepository =
           unavailableRepository ?? const UnavailableFeedbackRepository();

  final FeedbackRepository? Function() _currentRepository;
  final FeedbackRepository _unavailableRepository;

  FeedbackRepository get _repository {
    try {
      return _currentRepository() ?? _unavailableRepository;
    } catch (_) {
      // Optional SDK state can change outside the local UI lifecycle.
      return _unavailableRepository;
    }
  }

  @override
  bool get isAvailable => _repository.isAvailable;

  @override
  Future<FeedbackSubmitResult> submitFeedback(FeedbackSubmission submission) =>
      _repository.submitFeedback(submission);

  @override
  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
    required String locale,
  }) => _repository.submitContactInquiry(
    inquiryType: inquiryType,
    email: email,
    details: details,
    locale: locale,
  );
}

/// A deliberate local failure, rather than an SDK singleton exception.
class UnavailableFeedbackRepository implements FeedbackRepository {
  const UnavailableFeedbackRepository();

  @override
  bool get isAvailable => false;

  @override
  Future<FeedbackSubmitResult> submitFeedback(FeedbackSubmission submission) {
    return Future.value(
      const FeedbackSubmitFailure(FeedbackSubmissionFailure.unavailable),
    );
  }

  @override
  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
    required String locale,
  }) => Future<void>.error(const FeedbackRepositoryUnavailable());
}

class FeedbackRepositoryUnavailable implements Exception {
  const FeedbackRepositoryUnavailable();

  @override
  String toString() => 'FeedbackRepositoryUnavailable';
}
