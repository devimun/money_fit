import 'dart:io';

import 'package:flutter/material.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactUsDialog extends StatefulWidget {
  const ContactUsDialog({super.key});

  @override
  State<ContactUsDialog> createState() => _ContactUsDialogState();
}

class _ContactUsDialogState extends State<ContactUsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _detailsController = TextEditingController();
  String? _selectedInquiryType;

  @override
  void dispose() {
    _emailController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseWait)),
      );

      try {
        final uid = Supabase.instance.client.auth.currentUser?.id;
        await Supabase.instance.client.from('user_contact').insert({
          if (uid != null) 'uid': uid,
          'inquiry_type': _selectedInquiryType,
          'email': _emailController.text,
          'details': _detailsController.text,
          'platform': Platform.isIOS
              ? 'ios'
              : (Platform.isAndroid ? 'android' : 'other'),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.inquirySuccess),
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (error) {
        debugPrint('Contact us error: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.inquiryFailure),
            ),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final inquiryTypes = [
      l10n.inquiryTypeBugReport,
      l10n.inquiryTypeFeatureSuggestion,
      l10n.inquiryTypeGeneralInquiry,
      l10n.inquiryTypeOther,
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
                Text(
                  l10n.contactUs,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
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
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedInquiryType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
                        value.isNotEmpty &&
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
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
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
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
                    child: Text(l10n.submit, style: context.textTheme.labelLarge),
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
