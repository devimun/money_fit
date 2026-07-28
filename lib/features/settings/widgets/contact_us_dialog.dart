import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_fit/core/analytics/analytics_event.dart';
import 'package:money_fit/core/providers/analytics_provider.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:money_fit/features/settings/model/inquiry_type.dart';
import 'package:money_fit/features/settings/repository/contact_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactUsDialog extends ConsumerStatefulWidget {
  const ContactUsDialog({super.key});

  @override
  ConsumerState<ContactUsDialog> createState() => _ContactUsDialogState();
}

class _ContactUsDialogState extends ConsumerState<ContactUsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _detailsController = TextEditingController();
  InquiryType? _selectedInquiryType;
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
      await ref
          .read(contactRepositoryProvider)
          .submit(
            type: _selectedInquiryType!,
            email: _emailController.text,
            details: _detailsController.text,
            locale: Localizations.localeOf(context).languageCode,
          );

      unawaited(
        ref.read(analyticsProvider).track(AnalyticsEvent.inquirySubmitted, {
          'inquiry_type': _selectedInquiryType!.wire,
          'result': 'success',
        }),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.inquirySuccess)),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      unawaited(
        ref.read(analyticsProvider).track(AnalyticsEvent.inquirySubmitted, {
          'inquiry_type': _selectedInquiryType!.wire,
          'result': 'failure',
        }),
      );
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.inquiryFailure)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final inquiryTypes = <(InquiryType, String)>[
      (InquiryType.bugReport, l10n.inquiryTypeBugReport),
      (InquiryType.featureSuggestion, l10n.inquiryTypeFeatureSuggestion),
      (InquiryType.generalInquiry, l10n.inquiryTypeGeneralInquiry),
      (InquiryType.other, l10n.inquiryTypeOther),
    ];

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
                DropdownButtonFormField<InquiryType>(
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
                  items: inquiryTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type.$1,
                          child: Text(type.$2),
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
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        !ContactRepository.isValidEmail(value.trim())) {
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
                    if (value == null || value.trim().isEmpty) {
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
                            width: 20,
                            height: 20,
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
