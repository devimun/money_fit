import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/models/category_model.dart';
import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/providers/repository_providers.dart';
import 'package:money_fit/features/settings/viewmodel/user_settings_provider.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class CategoryProviders extends AsyncNotifier<List<Category>> {
  // 처음 로드될 시 db에서 카테고리를 전부 가져오게 한다.
  @override
  FutureOr<List<Category>> build() async {
    final user = await ref.read(userSettingsProvider.future);
    List<Category> userCategory = await ref
        .read(categoryRepositoryProvider)
        .getAllCategories(user.id);
    return userCategory;
  }

  // 카테고리를 추가하는 메서드
  Future<void> createCategory(Category newCategory) async {
    await ref.read(categoryRepositoryProvider).createCategory(newCategory);
    List<Category> currentState = state.value ?? [];
    List<Category> newState = List<Category>.from(currentState);
    newState.add(newCategory);
    state = AsyncData(newState);
  }

  // 카테고리를 삭제하는 메서드
  Future<void> deleteCategory(Category deleteCategory) async {
    await ref
        .read(categoryRepositoryProvider)
        .deleteCategory(deleteCategory.id);
    List<Category> currentState = state.value ?? [];
    List<Category> newState = List<Category>.from(currentState);
    newState.remove(deleteCategory);
    state = AsyncData(newState);
  }

  //카테고리를 매핑해주는 메서드
  String getCategoryName(BuildContext context, String categoryId) {
    final l10n = AppLocalizations.of(context)!;
    switch (categoryId) {
      case 'food':
        return l10n.category_food;
      case 'traffic':
        return l10n.category_traffic;
      case 'insurance':
        return l10n.category_insurance;
      case 'necessities':
        return l10n.category_necessities;
      case 'communication':
        return l10n.category_communication;
      case 'housing':
        return l10n.category_housing;
      case 'medical':
        return l10n.category_medical;
      case 'finance':
        return l10n.category_finance;
      case 'eating-out':
        return l10n.categoryEatingOut;
      case 'cafe':
        return l10n.category_cafe;
      case 'shopping':
        return l10n.category_shopping;
      case 'hobby':
        return l10n.category_hobby;
      case 'travel':
        return l10n.category_travel;
      case 'subscribe':
        return l10n.category_subscribe;
      case 'beauty':
        return l10n.category_beauty;
      default:
        final value = state.value ?? [];
        final category = value.firstWhere(
          (c) => c.id == categoryId,
          orElse: () => Category(
            id: '',
            name: AppLocalizations.of(context)!.unknown,
            type: ExpenseType.n,
            isDeletable: false,
          ),
        );
        return category.name;
    }
  }
}

final categoryProvider =
    AsyncNotifierProvider<CategoryProviders, List<Category>>(
      () => CategoryProviders(),
    );
