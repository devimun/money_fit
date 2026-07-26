#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"

fail() {
  printf 'asset/config validation failed: %s\n' "$*" >&2
  exit 1
}

# Runtime settings must come from dart defines through AppEnvironment, not from
# a checkout-specific dotenv asset.
if grep -Eq '^\s*-\s*\.env\s*$' pubspec.yaml; then
  fail '.env must not be declared as a Flutter runtime asset'
fi

if grep -Eq '^\s*flutter_dotenv\s*:' pubspec.yaml; then
  fail 'flutter_dotenv must not be a production dependency'
fi

if grep -R --include='*.dart' -n -E 'flutter_dotenv|dotenv\.' lib; then
  fail 'production Dart code must not read dotenv directly'
fi

if git ls-files --error-unmatch .env >/dev/null 2>&1; then
  fail '.env must not be tracked'
fi

font_path='assets/fonts/PretendardVariable.ttf'
license_path='assets/fonts/LICENSE-Pretendard-1.3.9.txt'

[[ -s "$font_path" ]] || fail "$font_path is missing or empty"
[[ -s "$license_path" ]] || fail "$license_path is missing or empty"

font_type="$(file --brief "$font_path")"
case "$font_type" in
  *'TrueType'* | *'OpenType'*) ;;
  *) fail "$font_path is not a font binary (detected: $font_type)" ;;
esac

if head -c 512 "$font_path" | grep -Eqi '<!doctype html|<html'; then
  fail "$font_path looks like an HTML response, not a font binary"
fi

printf 'asset/config validation passed\n'
