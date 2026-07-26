import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/features/feedback/data/supabase_feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (ref) => SupabaseFeedbackRepository(Supabase.instance.client),
);
