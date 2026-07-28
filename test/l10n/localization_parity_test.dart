import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every supported ARB has exactly the template message keys', () {
    final directory = Directory('lib/l10n');
    final template = _messageKeys(File('${directory.path}/app_en.arb'));

    final localeFiles =
        directory
            .listSync()
            .whereType<File>()
            .where((file) => RegExp(r'app_[a-z]+\.arb$').hasMatch(file.path))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));

    expect(localeFiles, hasLength(14));
    for (final file in localeFiles) {
      expect(
        _messageKeys(file),
        template,
        reason: '${file.path} must match app_en.arb',
      );
    }
  });
}

Set<String> _messageKeys(File file) {
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return decoded.keys.where((key) => !key.startsWith('@')).toSet();
}
