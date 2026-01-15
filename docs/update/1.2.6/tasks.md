# 업데이트 테스크 - v1.4.7

---

## Part A: 테마 시스템 리팩토링 (완료)

### 1단계: 코어 테마 시스템 구축
- [x] `AppThemeColors` ThemeExtension 구현 (22개 색상 속성)
- [x] `AppThemeGenerator` 팩토리 클래스 구현 (colorSeed → 테마 생성)
- [x] `BuildContext Extension` 구현 (`context.colors`, `context.textTheme`)
- [x] `AppTextStyles` 색상 제거 (폰트 크기/가중치만 유지)
- [x] `ThemeSettings` 데이터 모델 구현 (JSON 직렬화)
- [x] `ThemeRepository` 구현 (SharedPreferences 영구 저장)
- [x] `ThemeProvider` Riverpod 연동

### 2단계: 사용자 커스터마이징 UI
- [x] `PresetColorsGrid` 위젯 (8개 프리셋 색상)
- [x] `RecentColorsGrid` 위젯 (최근 사용 색상)
- [x] `HSVColorPicker` 위젯 (자유 색상 선택)
- [x] `ThemePreviewCard` 위젯 (실시간 미리보기)
- [x] `ColorPickerDialog` 통합 다이얼로그
- [x] Settings 화면에 테마 색상 변경 메뉴 추가

### 3단계: 폰트 크기 커스터마이징
- [x] `ThemeSettings`에 `fontSizeScale` 필드 추가
- [x] `FontSizeNotifier` Provider 구현
- [x] `TextTheme`에 폰트 크기 스케일 적용
- [x] `FontSizeSetting` 위젯 Provider 연동

### 4단계: 마이그레이션
- [x] `LightAppColors`/`DarkAppColors` Deprecated 처리
- [x] Home 화면 마이그레이션
- [x] Calendar 화면 마이그레이션
- [x] Expense 화면 마이그레이션
- [x] Settings 화면 마이그레이션
- [x] Onboarding 화면 마이그레이션
- [x] 공통 위젯 마이그레이션

### 5단계: 테스트
- [x] Property-Based Tests (색상 일관성, 대비율, 라운드트립)
- [x] Unit Tests (각 컴포넌트별)
- [x] Widget Tests (UI 컴포넌트)

---

## Part B: 유럽 시장 확장 (언어 현지화)

## 1단계: 핵심 현지화 (최우선)
- [ ] `app_es.arb` (스페인어) 생성 (기준: `app_ko.arb`)
- [ ] `app_pl.arb` (폴란드어) 생성
- [ ] 핵심 기능(온보딩, 홈, 지출 입력) 번역 품질 검수
- [ ] `flutter gen-l10n` 실행 및 빌드 오류 확인

## 2단계: 2차 현지화 (우선)
- [ ] `app_uk.arb` (우크라이나어) 생성
- [ ] `app_cs.arb` (체코어) 생성
- [ ] 슬라브어권 특유의 긴 단어에 따른 UI 레이아웃 검토

## 3단계: 3차 현지화 (잠재적 중요군)
- [ ] `app_de.arb` (독일어) 생성
- [ ] `app_it.arb` (이탈리아어) 생성

## 4단계: UI/UX 기능 구현
- [ ] **설정 화면 개선**:
    - [ ] '언어 설정' 리스트 아이템 추가
    - [ ] 언어 선택 바텀시트 또는 다이얼로그 구현
    - [ ] Provider를 이용한 실시간 로케일 변경 로직 적용
- [ ] **데이터 유지**:
    - [ ] 선택한 언어 설정을 `SharedPreferences`에 저장하여 앱 재시작 시 유지
- [ ] **UI 레이아웃 리뷰**:
    - [ ] 홈 화면 카드 및 통계 화면의 텍스트 오버플로우 확인
    - [ ] 각 언어별 날짜 포맷(Date Format) 적용 확인

## 5단계: 검증 및 배포 준비
- [ ] 언어 전환 기능 단위 테스트
- [ ] 추가된 모든 언어에 대한 수동 스모크 테스트
- [ ] 업데이트 로그(`1.3.0.md` 등) 및 `CHANGELOG.md` 최신화