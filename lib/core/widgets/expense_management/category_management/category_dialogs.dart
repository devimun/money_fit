import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/category_model.dart' as category_model;
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/category_providers.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

/// 카테고리 관련 다이얼로그들을 관리하는 클래스
class CategoryDialogs {
  /// 새 카테고리 추가 다이얼로그 표시
  static Future<void> showAddCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    ExpenseType type,
    String uid,
  ) async {
    final TextEditingController categoryNameController =
        TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        AppLocalizations l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.addNewCategory),
          content: TextField(
            controller: categoryNameController,
            decoration: InputDecoration(labelText: l10n.categoryName),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final categoryName = categoryNameController.text.trim();
                if (categoryName.isNotEmpty) {
                  final newCategory = category_model.Category(
                    id: const Uuid().v4(),
                    userId: uid,
                    name: categoryName,
                    type: type,
                    isDeletable: true,
                  );
                  await ref
                      .read(categoryProvider.notifier)
                      .createCategory(newCategory);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  /// 카테고리 삭제 확인 다이얼로그 표시
  static Future<void> showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    category_model.Category category,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        AppLocalizations l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.deleteCategory),
          content: Text(l10n.deleteCategoryPrompt(category.name)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(categoryProvider.notifier)
                    .deleteCategory(category);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }
}
