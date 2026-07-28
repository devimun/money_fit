import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_fit/core/platform/analytics_event.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/contact_inquiry_validation.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class ContactUsDialog extends StatefulWidget {
  const ContactUsDialog({
    required this.repository,
    this.analytics = const NoopAnalyticsTracker(),
    super.key,
  });

  final FeedbackRepository repository;
  final AnalyticsTracker analytics;

  @override
  State<ContactUsDialog> createState() => _ContactUsDialogState();
}

class _ContactUsDialogState extends State<ContactUsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _detailsController = TextEditingController();
  ContactInquiryType? _selectedInquiryType;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);

    try {
      await widget.repository.submitContactInquiry(
        inquiryType: _selectedInquiryType!,
        email: _emailController.text,
        details: _detailsController.text,
        locale: Localizations.localeOf(context).toString(),
      );
      unawaited(_track('success'));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.inquirySuccess)),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      debugPrint('Contact us error: $error');
      unawaited(_track('failure'));
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.inquiryFailure)),
        );
      }
    }
  }

  Future<void> _track(String result) async {
    try {
      await widget.analytics.track(
        AnalyticsEvent.inquirySubmitted.canonicalName,
        parameters: {
          'inquiry_type': _selectedInquiryType!.backendCode,
          'result': result,
        },
      );
    } catch (_) {
      // Contact delivery must retain its success/failure UX when analytics is
      // unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final inquiryTypes = <ContactInquiryType, String>{
      ContactInquiryType.bugReport: l10n.inquiryTypeBugReport,
      ContactInquiryType.featureSuggestion: l10n.inquiryTypeFeatureSuggestion,
      ContactInquiryType.generalInquiry: l10n.inquiryTypeGeneralInquiry,
      ContactInquiryType.other: l10n.inquiryTypeOther,
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.colors.brandPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.contact_support_outlined,
                    size: 40,
                    color: context.colors.brandPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                ResponsiveTitleText(
                  text: l10n.contactUs,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<ContactInquiryType>(
                  initialValue: _selectedInquiryType,
                  decoration: InputDecoration(
                    labelText: l10n.inquiryType,
                    filled: true,
                    fillColor: context.colors.textPrimary.withValues(
                      alpha: 0.05,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  items: inquiryTypes.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedInquiryType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '${l10n.replyEmail} (${l10n.optional})',
                    hintStyle: context.textTheme.bodySmall,
                    hintText: 'example@email.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (!FeedbackContactInquiryValidation.hasValidOptionalEmail(
                      value ?? '',
                    )) {
                      return l10n.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detailsController,
                  decoration: InputDecoration(
                    labelText: l10n.inquiryDetails,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 5,
                  maxLength: 500,
                  validator: (value) {
                    if (!FeedbackContactInquiryValidation.hasValidDetails(
                      value ?? '',
                    )) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.brandPrimary,
                    foregroundColor: context.colors.textOnBrand,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Center(
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : ResponsiveButtonText(
                            text: l10n.submit,
                            style: context.textTheme.labelLarge,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
