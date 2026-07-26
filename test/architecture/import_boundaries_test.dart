import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'allowed_legacy_imports.dart';

void main() {
  final sourceFiles = _dartFilesUnder('lib');

  test(
    'core-to-feature imports match the reviewed compatibility allowlist',
    () {
      final actualImports = <_BoundaryUse>[];

      for (final file in sourceFiles.where(
        (file) => file.path.startsWith('lib/core/'),
      )) {
        for (final uri in _importUris(file.readAsStringSync())) {
          if (uri.startsWith('package:money_fit/features/')) {
            actualImports.add(
              _BoundaryUse(
                filePath: file.path,
                kind: LegacyBoundaryKind.coreToFeatureImport,
                target: uri,
              ),
            );
          }
        }
      }

      _expectExactAllowlist(
        actualUses: actualImports,
        kind: LegacyBoundaryKind.coreToFeatureImport,
      );
    },
  );

  test('feature domain stays free of Flutter, Riverpod, database, and SDKs', () {
    final forbidden = RegExp(
      r'''^import\s+['"]package:(?:flutter(?:/|_)|flutter_riverpod/|sqflite|firebase|supabase)''',
      multiLine: true,
    );
    final violations = <String>[];

    for (final file in sourceFiles.where(
      (file) => file.path.contains('/domain/'),
    )) {
      if (forbidden.hasMatch(file.readAsStringSync())) {
        violations.add(file.path);
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Feature domain imports platform dependencies: $violations',
    );
  });

  test('data and services do not gain UI context dependencies', () {
    final actualUses = <_BoundaryUse>[];

    for (final file in sourceFiles.where(_isDataOrService)) {
      final contents = file.readAsStringSync();
      for (final type in const ['BuildContext', 'WidgetRef']) {
        final count = RegExp('\\b$type\\b').allMatches(contents).length;
        if (count > 0) {
          actualUses.add(
            _BoundaryUse(
              filePath: file.path,
              kind: LegacyBoundaryKind.serviceUiType,
              target: type,
              occurrences: count,
            ),
          );
        }
      }
    }

    _expectExactAllowlist(
      actualUses: actualUses,
      kind: LegacyBoundaryKind.serviceUiType,
    );
  });

  test('feature presentation does not import another feature presentation', () {
    final presentationImport = RegExp(
      r'''^import\s+['"]package:money_fit/features/([^/]+)/presentation/''',
      multiLine: true,
    );
    final violations = <String>[];

    for (final file in sourceFiles.where(
      (file) => file.path.contains('/presentation/'),
    )) {
      final ownFeature = _featureNameFor(file.path);
      for (final match in presentationImport.allMatches(
        file.readAsStringSync(),
      )) {
        if (match.group(1) != ownFeature) {
          violations.add('${file.path} -> ${match.group(1)}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Presentation imports another feature presentation: $violations',
    );
  });

  test(
    'SDK and database singletons stay in main/app or the reviewed allowlist',
    () {
      final singleton = RegExp(
        r'\b(?:Firebase\w*|Supabase|DatabaseHelper)\.instance\b',
      );
      final actualUses = <_BoundaryUse>[];

      for (final file in sourceFiles.where(
        (file) =>
            file.path != 'lib/main.dart' && !file.path.startsWith('lib/app/'),
      )) {
        final contents = file.readAsStringSync();
        final matches = singleton.allMatches(contents);
        final counts = <String, int>{};
        for (final match in matches) {
          final target = match.group(0)!;
          counts[target] = (counts[target] ?? 0) + 1;
        }
        for (final entry in counts.entries) {
          actualUses.add(
            _BoundaryUse(
              filePath: file.path,
              kind: LegacyBoundaryKind.sdkSingleton,
              target: entry.key,
              occurrences: entry.value,
            ),
          );
        }
      }

      _expectExactAllowlist(
        actualUses: actualUses,
        kind: LegacyBoundaryKind.sdkSingleton,
      );
    },
  );
}

void _expectExactAllowlist({
  required List<_BoundaryUse> actualUses,
  required LegacyBoundaryKind kind,
}) {
  final expected = allowedLegacyImports.where((entry) => entry.kind == kind);
  final actualByKey = {for (final use in actualUses) use.key: use};
  final expectedByKey = {for (final use in expected) use.key: use};
  final violations = <String>[];

  for (final actual in actualUses) {
    final allowance = expectedByKey[actual.key];
    if (allowance == null) {
      violations.add(
        'Unexpected ${kind.name}: ${actual.filePath} -> ${actual.target}',
      );
    } else if (actual.occurrences != allowance.expectedOccurrences) {
      violations.add(
        'Changed ${kind.name}: ${actual.filePath} -> ${actual.target}; '
        'expected ${allowance.expectedOccurrences}, found ${actual.occurrences}.',
      );
    }
  }
  for (final allowance in expected) {
    if (!actualByKey.containsKey(allowance.key)) {
      violations.add('Stale allowlist entry: $allowance');
    }
  }

  expect(violations, isEmpty, reason: violations.join('\n'));
}

bool _isDataOrService(File file) =>
    file.path.contains('/data/') || file.path.contains('/services/');

String? _featureNameFor(String filePath) {
  final match = RegExp(r'^lib/features/([^/]+)/').firstMatch(filePath);
  return match?.group(1);
}

Iterable<String> _importUris(String source) sync* {
  final imports = RegExp(r'''^import\s+['"]([^'"]+)['"]''', multiLine: true);
  for (final match in imports.allMatches(source)) {
    yield match.group(1)!;
  }
}

List<File> _dartFilesUnder(String path) =>
    Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList()
      ..sort((left, right) => left.path.compareTo(right.path));

class _BoundaryUse {
  const _BoundaryUse({
    required this.filePath,
    required this.kind,
    required this.target,
    this.occurrences = 1,
  });

  final String filePath;
  final LegacyBoundaryKind kind;
  final String target;
  final int occurrences;

  String get key => '${kind.name}:$filePath:$target';
}

extension on LegacyBoundaryAllowance {
  String get key => '${kind.name}:$filePath:$target';
}
