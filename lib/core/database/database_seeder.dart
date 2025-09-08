import 'dart:math' as math;

import 'package:money_fit/core/models/expense_model.dart';
import 'package:money_fit/core/repositories/expense_repository.dart';
import 'package:uuid/uuid.dart';

class UserIDD {
  static const String id = '8299b05a-1ec2-4c16-abbe-7218372fbbb6';
}

class DatabaseSeeder {
  final IExpenseRepository _expenseRepository;

  DatabaseSeeder({required IExpenseRepository expenseRepository})
    : _expenseRepository = expenseRepository;

  /// Generates dummy expense data for July for testing purposes.
  /// This data is localized for different regions (en, ko, id, ms)
  /// and uses currency scales appropriate for a student budget in each region.
  Future<void> seedJulyExpenses({String locale = 'en'}) async {
    final random = math.Random();
    final year = 2025;
    final month = 7;

    final localizedData = _getLocalizedData();
    final categoryDetails = localizedData[locale] ?? localizedData['en']!;
    final categoryIds = categoryDetails.keys.toList();

    final fixedMonthlyCategories = ['communication', 'housing', 'subscribe'];
    final fixedCategoryAssignedDates = <String, int>{};

    // 한 달에 한 번만 나와야 할 항목들 → 임의의 날짜에 고정
    for (final categoryId in fixedMonthlyCategories) {
      fixedCategoryAssignedDates[categoryId] = random.nextInt(31) + 1;
    }

    for (int day = 1; day <= 31; day++) {
      final date = DateTime(year, month, day);
      final addedEssentialCategories = <String>{};
      final expenseCount = random.nextInt(4) + 1;

      for (int i = 0; i < expenseCount; i++) {
        final categoryId = categoryIds[random.nextInt(categoryIds.length)];
        final categoryInfo = categoryDetails[categoryId]!;
        final isEssential = categoryInfo['type'] == ExpenseType.essential;

        // 한 달에 한 번만 등장해야 하는 항목이면, 해당 날짜에만 통과
        if (fixedMonthlyCategories.contains(categoryId)) {
          final assignedDay = fixedCategoryAssignedDates[categoryId]!;
          if (day != assignedDay) continue;
        }

        // 같은 날 중복 생성 방지 (필수 항목만)
        if (isEssential && addedEssentialCategories.contains(categoryId)) {
          continue;
        }

        final examples = categoryInfo['examples'] as List<String>;
        final name = examples[random.nextInt(examples.length)];

        final range = categoryInfo['range'] as Map<String, double>;
        final minAmount = range['min']!;
        final maxAmount = range['max']!;

        // 현실적인 가격 분포 (정규분포 근사)
        double amount =
            minAmount +
            (random.nextDouble() + random.nextDouble()) /
                2 *
                (maxAmount - minAmount);

        final finalAmount = (locale == 'ko' || locale == 'id')
            ? amount.roundToDouble()
            : (amount * 100).round() / 100;

        final expense = Expense(
          id: const Uuid().v4(),
          userId: UserIDD.id,
          name: name,
          amount: finalAmount,
          date: date,
          categoryId: categoryId,
          type: categoryInfo['type'] as ExpenseType,
          createdAt: date,
          updatedAt: date,
        );

        await _expenseRepository.createExpense(expense);

        if (isEssential) {
          addedEssentialCategories.add(categoryId);
        }
      }
    }
  }

  Map<String, Map<String, Map<String, dynamic>>> _getLocalizedData() {
    return {
      'en': {
        // Essential (Student Budget, USD-like scale)
        'food': {
          'type': ExpenseType.essential,
          'examples': ['Campus lunch', 'Groceries', 'Ramen noodles'],
          'range': {'min': 5.0, 'max': 40.0},
        },
        'traffic': {
          'type': ExpenseType.essential,
          'examples': ['Bus fare', 'Subway pass'],
          'range': {'min': 2.0, 'max': 20.0},
        },
        'communication': {
          'type': ExpenseType.essential,
          'examples': ['Phone bill'],
          'range': {'min': 25.0, 'max': 60.0},
        },
        'housing': {
          'type': ExpenseType.essential,
          'examples': ['Dorm utilities', 'Shared apartment rent part'],
          'range': {'min': 200.0, 'max': 500.0},
        },
        'necessities': {
          'type': ExpenseType.essential,
          'examples': ['Textbooks', 'Shampoo', 'Detergent'],
          'range': {'min': 10.0, 'max': 50.0},
        },
        // Discretionary
        'eating-out': {
          'type': ExpenseType.discretionary,
          'examples': ['Pizza with friends', 'Weekend brunch'],
          'range': {'min': 10.0, 'max': 30.0},
        },
        'cafe': {
          'type': ExpenseType.discretionary,
          'examples': ['Coffee', 'Bubble tea'],
          'range': {'min': 3.0, 'max': 8.0},
        },
        'shopping': {
          'type': ExpenseType.discretionary,
          'examples': ['T-shirt', 'Online shopping'],
          'range': {'min': 15.0, 'max': 100.0},
        },
        'hobby': {
          'type': ExpenseType.discretionary,
          'examples': ['Movie ticket', 'Gaming skin'],
          'range': {'min': 10.0, 'max': 40.0},
        },
        'subscribe': {
          'type': ExpenseType.discretionary,
          'examples': ['Streaming service', 'Music subscription'],
          'range': {'min': 5.0, 'max': 15.0},
        },
      },
      'ko': {
        // 필수 (학생 예산, KRW 단위)
        'food': {
          'type': ExpenseType.essential,
          'examples': ['학식', '편의점 도시락', '마트 장보기'],
          'range': {'min': 4000.0, 'max': 30000.0},
        },
        'traffic': {
          'type': ExpenseType.essential,
          'examples': ['버스 요금', '지하철 요금'],
          'range': {'min': 1500.0, 'max': 10000.0},
        },
        'communication': {
          'type': ExpenseType.essential,
          'examples': ['알뜰폰 요금'],
          'range': {'min': 15000.0, 'max': 40000.0},
        },
        'housing': {
          'type': ExpenseType.essential,
          'examples': ['기숙사비', '자취방 공과금'],
          'range': {'min': 150000.0, 'max': 400000.0},
        },
        'necessities': {
          'type': ExpenseType.essential,
          'examples': ['전공 서적', '샴푸', '세제'],
          'range': {'min': 8000.0, 'max': 40000.0},
        },
        // 자율
        'eating-out': {
          'type': ExpenseType.discretionary,
          'examples': ['친구랑 떡볶이', '주말 데이트'],
          'range': {'min': 8000.0, 'max': 25000.0},
        },
        'cafe': {
          'type': ExpenseType.discretionary,
          'examples': ['아메리카노', '버블티'],
          'range': {'min': 2000.0, 'max': 7000.0},
        },
        'shopping': {
          'type': ExpenseType.discretionary,
          'examples': ['온라인 쇼핑', '옷 구매'],
          'range': {'min': 10000.0, 'max': 80000.0},
        },
        'hobby': {
          'type': ExpenseType.discretionary,
          'examples': ['PC방', '영화 관람', '코인 노래방'],
          'range': {'min': 5000.0, 'max': 30000.0},
        },
        'subscribe': {
          'type': ExpenseType.discretionary,
          'examples': ['OTT 서비스', '음악 스트리밍'],
          'range': {'min': 4000.0, 'max': 15000.0},
        },
      },
      'id': {
        // Essential (Student Budget, IDR scale)
        'food': {
          'type': ExpenseType.essential,
          'examples': ['Makan di warteg', 'Belanja di pasar', 'Nasi goreng'],
          'range': {'min': 15000.0, 'max': 50000.0},
        },
        'traffic': {
          'type': ExpenseType.essential,
          'examples': ['Ongkos ojek', 'Naik angkot'],
          'range': {'min': 5000.0, 'max': 25000.0},
        },
        'communication': {
          'type': ExpenseType.essential,
          'examples': ['Pulsa', 'Paket data'],
          'range': {'min': 50000.0, 'max': 150000.0},
        },
        'housing': {
          'type': ExpenseType.essential,
          'examples': ['Bayar kosan', 'Listrik & air'],
          'range': {'min': 500000.0, 'max': 1500000.0},
        },
        'necessities': {
          'type': ExpenseType.essential,
          'examples': ['Buku kuliah', 'Sabun', 'Deterjen'],
          'range': {'min': 20000.0, 'max': 100000.0},
        },
        // Discretionary
        'eating-out': {
          'type': ExpenseType.discretionary,
          'examples': ['Makan di kafe', 'Traktir teman'],
          'range': {'min': 30000.0, 'max': 100000.0},
        },
        'cafe': {
          'type': ExpenseType.discretionary,
          'examples': ['Kopi susu', 'Es teh'],
          'range': {'min': 10000.0, 'max': 30000.0},
        },
        'shopping': {
          'type': ExpenseType.discretionary,
          'examples': ['Baju baru', 'Belanja online'],
          'range': {'min': 50000.0, 'max': 300000.0},
        },
        'hobby': {
          'type': ExpenseType.discretionary,
          'examples': ['Nonton bioskop', 'Top-up game'],
          'range': {'min': 35000.0, 'max': 150000.0},
        },
        'subscribe': {
          'type': ExpenseType.discretionary,
          'examples': ['Langganan streaming', 'Musik online'],
          'range': {'min': 25000.0, 'max': 75000.0},
        },
      },
      'ms': {
        // Essential (Student Budget, MYR scale)
        'food': {
          'type': ExpenseType.essential,
          'examples': [
            'Makan di kafe kolej',
            'Beli barang dapur',
            'Nasi lemak',
          ],
          'range': {'min': 5.0, 'max': 20.0},
        },
        'traffic': {
          'type': ExpenseType.essential,
          'examples': ['Tambang bas', 'Naik LRT'],
          'range': {'min': 2.0, 'max': 10.0},
        },
        'communication': {
          'type': ExpenseType.essential,
          'examples': ['Bil telefon', 'Top up'],
          'range': {'min': 20.0, 'max': 50.0},
        },
        'housing': {
          'type': ExpenseType.essential,
          'examples': ['Sewa bilik', 'Bil utiliti'],
          'range': {'min': 200.0, 'max': 450.0},
        },
        'necessities': {
          'type': ExpenseType.essential,
          'examples': ['Buku teks', 'Syampu', 'Sabun'],
          'range': {'min': 10.0, 'max': 40.0},
        },
        // Discretionary
        'eating-out': {
          'type': ExpenseType.discretionary,
          'examples': ['Makan dengan kawan', 'Lepak di mamak'],
          'range': {'min': 10.0, 'max': 30.0},
        },
        'cafe': {
          'type': ExpenseType.discretionary,
          'examples': ['Kopi', 'Teh tarik'],
          'range': {'min': 3.0, 'max': 8.0},
        },
        'shopping': {
          'type': ExpenseType.discretionary,
          'examples': ['Baju baru', 'Beli online'],
          'range': {'min': 20.0, 'max': 100.0},
        },
        'hobby': {
          'type': ExpenseType.discretionary,
          'examples': ['Tengok wayang', 'Main game'],
          'range': {'min': 10.0, 'max': 40.0},
        },
        'subscribe': {
          'type': ExpenseType.discretionary,
          'examples': ['Langganan Netflix', 'Spotify'],
          'range': {'min': 15.0, 'max': 30.0},
        },
      },
    };
  }
}
