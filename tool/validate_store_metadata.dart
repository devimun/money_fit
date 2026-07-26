import 'dart:convert';
import 'dart:io';

const _iosMetadataRoot = 'ios/fastlane/metadata';
const _androidMetadataRoot = 'android/fastlane/metadata/android';

const _iosCopy = <String, Map<String, String>>{
  'en-US': {
    'name': 'MoneyFit - Expense Tracker',
    'subtitle': 'Know what you can spend today',
    'keywords':
        'budget,spending,planner,money,savings,finance,calendar,simple,daily',
  },
  'en-GB': {
    'name': 'MoneyFit - Expense Tracker',
    'subtitle': 'Know what you can spend today',
    'keywords':
        'budget,spending,planner,money,savings,finance,calendar,simple,daily',
  },
  'ko': {
    'name': 'MoneyFit - 하루 예산 가계부',
    'subtitle': '오늘 쓸 수 있는 금액을 한눈에',
    'keywords': '지출관리,소비습관,돈관리,월예산,소비분석,용돈기입장',
  },
  'es-ES': {
    'name': 'MoneyFit - Control de gastos',
    'subtitle': 'Tu presupuesto diario simple',
    'keywords':
        'dinero,finanzas,ahorro,gestor,límite,mensual,seguimiento,calendario',
  },
  'pl': {
    'name': 'MoneyFit - Kontrola wydatków',
    'subtitle': 'Twój prosty budżet dzienny',
    'keywords':
        'finanse,pieniądze,oszczędności,limity,miesięczny,rejestr,portfel,kalendarz',
  },
  'uk': {
    'name': 'MoneyFit - Облік витрат',
    'subtitle': 'Твій простий щоденний бюджет',
    'keywords': 'фінанси,гроші,економія,ліміт,гаманець,місячний',
  },
  'cs': {
    'name': 'MoneyFit - Sledování výdajů',
    'subtitle': 'Jednoduchý denní rozpočet',
    'keywords': 'finance,peníze,úspory,limit,měsíční,evidence,kalendář',
  },
  'de-DE': {
    'name': 'MoneyFit - Haushaltsbuch',
    'subtitle': 'Dein einfaches Tagesbudget',
    'keywords':
        'ausgaben,tracker,finanzen,geld,sparen,limit,monatlich,kalender',
  },
  'it': {
    'name': 'MoneyFit - Gestione spese',
    'subtitle': 'Il tuo budget giornaliero',
    'keywords':
        'soldi,finanze,risparmio,limite,mensile,registro,semplice,calendario',
  },
  'ro': {
    'name': 'MoneyFit - Buget și cheltuieli',
    'subtitle': 'Vezi cât poți cheltui azi',
    'keywords':
        'bani,finanțe,economii,zilnic,lunar,monitorizare,simplu,personal',
  },
  'sk': {
    'name': 'MoneyFit - Výdavky a rozpočet',
    'subtitle': 'Koľko môžeš dnes minúť',
    'keywords':
        'financie,peniaze,úspory,denný,mesačný,sledovanie,kalendár,osobný',
  },
  'id': {
    'name': 'MoneyFit - Catatan Keuangan',
    'subtitle': 'Tahu batas belanja hari ini',
    'keywords':
        'anggaran,pengeluaran,uang,hemat,tabungan,harian,bulanan,pencatat,kalender',
  },
  'ms': {
    'name': 'MoneyFit - Rekod Perbelanjaan',
    'subtitle': 'Bajet harian yang ringkas',
    'keywords': 'kewangan,wang,simpanan,had,bulanan,jejak,jimat,kalendar',
  },
};

const _androidCopy = <String, Map<String, String>>{
  'en-US': {
    'title': 'MoneyFit - Expense Tracker',
    'short_description':
        'See exactly how much you can safely spend today. Simple daily budget.',
  },
  'ko-KR': {
    'title': 'MoneyFit - 하루 예산 가계부',
    'short_description': '오늘 얼마까지 써도 되는지 바로 확인하는 심플한 하루 예산 가계부',
  },
  'es-ES': {
    'title': 'MoneyFit - Control de gastos',
    'short_description':
        'Descubre cuánto puedes gastar hoy con un presupuesto diario simple.',
  },
  'pl-PL': {
    'title': 'MoneyFit - Kontrola wydatków',
    'short_description':
        'Sprawdź, ile możesz dziś wydać. Prosty budżet dzienny i kontrola wydatków.',
  },
  'uk': {
    'title': 'MoneyFit - Облік витрат',
    'short_description':
        'Дізнайся, скільки можна витратити сьогодні. Простий щоденний бюджет.',
  },
  'cs-CZ': {
    'title': 'MoneyFit - Sledování výdajů',
    'short_description':
        'Hned víš, kolik můžeš dnes utratit. Jednoduchý denní rozpočet.',
  },
  'de-DE': {
    'title': 'MoneyFit - Haushaltsbuch',
    'short_description':
        'Sieh sofort, wie viel du heute ausgeben kannst. Einfaches Tagesbudget.',
  },
  'it-IT': {
    'title': 'MoneyFit - Gestione spese',
    'short_description':
        'Scopri quanto puoi spendere oggi con un budget giornaliero semplice.',
  },
  'ro': {
    'title': 'MoneyFit - Buget și cheltuieli',
    'short_description':
        'Vezi cât poți cheltui azi. Buget zilnic simplu și evidența cheltuielilor.',
  },
  'sk': {
    'title': 'MoneyFit - Výdavky a rozpočet',
    'short_description':
        'Hneď vieš, koľko môžeš dnes minúť. Jednoduchý denný rozpočet.',
  },
  'bg': {
    'title': 'MoneyFit - Разходи и бюджет',
    'short_description':
        'Виж колко можеш да похарчиш днес. Лесен дневен бюджет и следене на разходи.',
  },
  'id': {
    'title': 'MoneyFit - Catatan Keuangan',
    'short_description':
        'Cek berapa yang aman dibelanjakan hari ini. Anggaran harian yang simpel.',
  },
  'ms-MY': {
    'title': 'MoneyFit - Rekod Perbelanjaan',
    'short_description':
        'Tahu jumlah yang boleh dibelanja hari ini. Bajet harian yang ringkas.',
  },
  'fil': {
    'title': 'MoneyFit - Budget at Gastos',
    'short_description':
        'Alamin kung magkano ang puwedeng gastusin ngayon. Simpleng budget araw-araw.',
  },
};

const _requiredIosFiles = <String>[
  'name.txt',
  'subtitle.txt',
  'keywords.txt',
  'description.txt',
  'support_url.txt',
  'marketing_url.txt',
  'privacy_url.txt',
];
final _forbiddenCopy = <RegExp>[
  RegExp(r'\bbest\b', caseSensitive: false),
  RegExp(r'#1', caseSensitive: false),
  RegExp(r'\bfree\b', caseSensitive: false),
  RegExp(r'\boffline\b', caseSensitive: false),
  RegExp(r'no login', caseSensitive: false),
  RegExp(r'100% private', caseSensitive: false),
  RegExp(r'\bdiscount\b|\bsale\b', caseSensitive: false),
  RegExp(r'\b(mint|ynab|monefy|spendee)\b', caseSensitive: false),
];

void main() {
  final validator = _Validator();
  validator.validateIos();
  validator.validateAndroid();
  validator.report();
  if (validator.errors.isNotEmpty) exitCode = 1;
}

class _Validator {
  final errors = <String>[];
  final warnings = <String>[];
  final metrics = <_Metric>[];

  void validateIos() {
    _checkExactLocaleSet(_iosMetadataRoot, _iosCopy.keys.toSet(), 'iOS');
    for (final entry in _iosCopy.entries) {
      final locale = entry.key;
      final directory = Directory('$_iosMetadataRoot/$locale');
      for (final fileName in _requiredIosFiles) {
        final file = File('${directory.path}/$fileName');
        if (!file.existsSync()) {
          _error('iOS/$locale: missing required $fileName');
          continue;
        }
        if (fileName == 'description.txt') {
          _validateNonEmptyText(file, 'iOS/$locale/$fileName');
        } else {
          final value = _readSingleValue(file, 'iOS/$locale/$fileName');
          if (fileName.endsWith('_url.txt')) {
            _validateUrl(value, 'iOS/$locale/$fileName');
          }
        }
      }
      _copyField(locale, 'name', 2, 30, entry.value['name']!);
      _copyField(locale, 'subtitle', 0, 30, entry.value['subtitle']!);
      final keywords = _readSingleValue(
        File('$_iosMetadataRoot/$locale/keywords.txt'),
        'iOS/$locale/keywords.txt',
      );
      _metric('iOS', locale, 'keywords', keywords, 100, bytes: true);
      if (utf8.encode(keywords).length > 100) {
        _error('iOS/$locale keywords must be at most 100 UTF-8 bytes');
      }
      _validateKeywords(keywords, 'iOS/$locale');
      _validateForbidden(locale, 'iOS', <String>[
        entry.value['name']!,
        entry.value['subtitle']!,
        keywords,
      ]);
    }
  }

  void validateAndroid() {
    _checkExactLocaleSet(
      _androidMetadataRoot,
      _androidCopy.keys.toSet(),
      'Android',
    );
    for (final entry in _androidCopy.entries) {
      final locale = entry.key;
      final directory = Directory('$_androidMetadataRoot/$locale');
      for (final fileName in const [
        'title.txt',
        'short_description.txt',
        'full_description.txt',
      ]) {
        final file = File('${directory.path}/$fileName');
        if (!file.existsSync()) {
          _error('Android/$locale: missing required $fileName');
        } else if (file.readAsStringSync().trim().isEmpty) {
          _error('Android/$locale/$fileName must not be empty.');
        }
      }
      _copyField(
        locale,
        'title',
        1,
        30,
        entry.value['title']!,
        platform: 'Android',
      );
      _copyField(
        locale,
        'short_description',
        1,
        80,
        entry.value['short_description']!,
        platform: 'Android',
      );
      _validateForbidden(locale, 'Android', <String>[
        entry.value['title']!,
        entry.value['short_description']!,
      ]);
      final video = File('${directory.path}/video.txt');
      if (video.existsSync() && video.readAsStringSync().trim().isEmpty) {
        warnings.add(
          'Android/$locale: empty optional video.txt; remove it or add a valid YouTube URL before upload.',
        );
      }
    }
  }

  void _copyField(
    String locale,
    String field,
    int minimum,
    int limit,
    String expected, {
    String platform = 'iOS',
  }) {
    final root = platform == 'iOS' ? _iosMetadataRoot : _androidMetadataRoot;
    final file = File('$root/$locale/$field.txt');
    if (!file.existsSync()) {
      return;
    }
    final value = _readSingleValue(file, '$platform/$locale/$field.txt');
    _metric(platform, locale, field, value, limit);
    final characters = value.runes.length;
    if (characters < minimum || characters > limit) {
      _error(
        '$platform/$locale $field must contain $minimum-$limit Unicode characters (found $characters).',
      );
    }
    if (value != expected) {
      _error(
        '$platform/$locale $field does not match the approved 1.2.7 ASO copy.',
      );
    }
  }

  String _readSingleValue(File file, String label) {
    if (!file.existsSync()) return '';
    final raw = file.readAsStringSync();
    final value = raw.trim();
    if (value.isEmpty) {
      _error('$label must not be empty.');
    }
    if (value.contains('\n') || value.contains('\r')) {
      _error('$label must be a single line.');
    }
    if (raw.replaceAll(RegExp(r'[\r\n]+$'), '') != value) {
      _error('$label has leading or trailing whitespace.');
    }
    return value;
  }

  void _validateNonEmptyText(File file, String label) {
    if (file.readAsStringSync().trim().isEmpty) {
      _error('$label must not be empty.');
    }
  }

  void _validateUrl(String value, String label) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      _error('$label must be a non-empty HTTPS URL.');
    }
  }

  void _validateKeywords(String value, String label) {
    if (value.contains(', ')) {
      _error('$label keywords must not contain spaces after commas.');
    }
    final tokens = value.split(',');
    if (tokens.any((token) => token.trim().isEmpty)) {
      _error('$label keywords contain an empty token.');
    }
    final normalized = tokens.map((token) => token.toLowerCase()).toList();
    if (normalized.toSet().length != normalized.length) {
      _error('$label keywords contain duplicates.');
    }
  }

  void _validateForbidden(String locale, String platform, List<String> values) {
    for (final pattern in _forbiddenCopy) {
      if (values.any(pattern.hasMatch)) {
        _error('$platform/$locale contains forbidden copy: ${pattern.pattern}');
      }
    }
  }

  void _checkExactLocaleSet(
    String root,
    Set<String> expected,
    String platform,
  ) {
    final actual = Directory(root)
        .listSync()
        .whereType<Directory>()
        .where(
          (directory) =>
              directory.path.split(Platform.pathSeparator).last !=
              'review_information',
        )
        .map(
          (directory) =>
              directory.uri.pathSegments[directory.uri.pathSegments.length - 2],
        )
        .toSet();
    for (final locale in expected.difference(actual)) {
      _error('$platform: missing locale directory $locale.');
    }
    for (final locale in actual.difference(expected)) {
      _error('$platform: unsupported or duplicate locale directory $locale.');
    }
  }

  void _metric(
    String platform,
    String locale,
    String field,
    String value,
    int limit, {
    bool bytes = false,
  }) {
    metrics.add(
      _Metric(
        platform,
        locale,
        field,
        value.runes.length,
        utf8.encode(value).length,
        limit,
        bytes,
      ),
    );
  }

  void _error(String message) => errors.add(message);

  void report() {
    stdout.writeln(
      '| Platform | Locale | Field | Unicode chars | UTF-8 bytes | Limit |',
    );
    stdout.writeln('| --- | --- | --- | ---: | ---: | --- |');
    for (final metric in metrics) {
      stdout.writeln(
        '| ${metric.platform} | ${metric.locale} | ${metric.field} | ${metric.characters} | ${metric.bytes} | ${metric.limit}${metric.bytesLimit ? " bytes" : " chars"} |',
      );
    }
    for (final warning in warnings) {
      stdout.writeln('WARNING: $warning');
    }
    for (final error in errors) {
      stderr.writeln('ERROR: $error');
    }
    stdout.writeln(
      errors.isEmpty
          ? 'Store metadata validation passed.'
          : 'Store metadata validation failed with ${errors.length} error(s).',
    );
  }
}

class _Metric {
  const _Metric(
    this.platform,
    this.locale,
    this.field,
    this.characters,
    this.bytes,
    this.limit,
    this.bytesLimit,
  );

  final String platform;
  final String locale;
  final String field;
  final int characters;
  final int bytes;
  final int limit;
  final bool bytesLimit;
}
