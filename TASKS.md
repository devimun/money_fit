<!-- @format -->

# MoneyFit: 개발 태스크 목록

이 문서는 MoneyFit 앱 개발을 위한 구체적인 태스크 목록을 정의합니다. 각 태스크는 `DEVELOPMENT_SPEC.md` 문서를 기반으로 합니다.

---

## Phase 0: 프로젝트 초기 설정

- [o] **프로젝트 생성 및 기본 설정**
  - [o] Flutter 프로젝트 생성 (`flutter create money_fit`)
  - [o] Git 저장소 초기화 및 `.gitignore` 설정
- [o] **의존성 추가 (`pubspec.yaml`)**
  - [o] `supabase_flutter` (향후 사용)
  - [o] `flutter_riverpod` 및 `riverpod_generator`
  - [o] `sqflite` 및 `path` (로컬 DB용)
  - [o] `uuid`
  - [o] `firebase_core`, `firebase_analytics`, `google_mobile_ads`
  - [o] `flutter_svg`
  - [o] `intl`
  - [o] `flutter pub get` 실행
- [o] **프로젝트 구조 설정**
  - [o] `lib` 폴더 내에 `data`, `models`, `providers`, `repositories`, `screens`, `utils`, `widgets` 등 폴더 구조 생성
- [o] **디자인 시스템 구현**
  - [o] `design_palette.dart` 파일에 정의된 `LightAppColors`, `DarkAppColors` 클래스 구현
  - [o] `AppTextStyles` 클래스 구현
  - [o] `main.dart`에서 라이트/다크 `ThemeData` 정의 및 연결
- [o] **외부 서비스 프로젝트 생성**
  - [o] Supabase 프로젝트 생성
  - [o] Firebase 프로젝트 생성 및 Flutter 앱 연동 (`flutterfire configure`)

---

## 📱 Phase 1: 로컬 구현 (MVP)e

### 1.1. 데이터 계층 (Data Layer)

- [o] **데이터 모델 클래스 작성**
  - [o] `lib/core/models/user_model.dart` 작성
  - [o] `lib/core/models/expense_model.dart` 작성
  - [o] `lib/core/models/category_model.dart` 작성
- [o] **로컬 데이터베이스 헬퍼 구현 (`sqflite`)**
  - [o] `lib/core/database/database_helper.dart` 파일 생성
  - [o] 데이터베이스 초기화 및 테이블 생성 로직 구현 (`users`, `categories`, `expenses`)
  - [o] 기본 카테고리 데이터 삽입 로직 구현
- [o] **리포지토리 구현 (Local Source)**
  - [o] `lib/core/repositories/user_repository.dart` (로컬 사용자 정보 CRUD)
  - [o] `lib/core/repositories/category_repository.dart` (카테고리 CRUD)
  - [o] `lib/core/repositories/expense_repository.dart` (지출 내역 CRUD)

### 1.2. 상태 관리 (State Management)

- [o] **Riverpod Provider 설정**
  - [o] `lib/core/providers/database_provider.dart`: `DatabaseHelper` 인스턴스를 제공하는 Provider
  - [o] `lib/core/providers/repository_providers.dart`: 각 리포지토리를 제공하는 Provider들
  - [o] `lib/features/settings/viewmodel/user_settings_provider.dart`: `User` 모델(설정 포함)을 관리하는 `StateNotifierProvider`
  - [o] 각 화면별 데이터(지출 목록, 캘린더 데이터 등)를 관리할 `AsyncNotifierProvider` 또는 `FutureProvider` 설정

### 1.3. UI 및 기능 구현

- [o] **온보딩 화면 (Onboarding Screen)**
  - [o] 앱 최초 실행 시 온보딩 스크린 표시
  - [o] 온보딩 완료 후 메인 화면으로 이동
- [o] **공통 위젯 구현**
  - [o] `lib/widgets/bottom_nav_bar.dart`: 메인 Bottom Navigation Bar 구현
  - [o] `lib/main.dart`: `MaterialApp`과 라우팅, 테마 설정
- [o] **설정 화면 (Settings Screen)**
  - [o] UI 레이아웃 구현 (기본 설정, 데이터 관리, 앱 정보 섹션)
  - [o] 일일 예산 설정 다이얼로그 및 기능 연동
  - [o] 다크 모드 토글 스위치 및 테마 전환 기능 연동
  - [o] 알림 설정 토글 스위치 기능 연동
  - [o] 데이터 초기화 기능 및 확인 다이얼로그 구현
- [o] **메인 화면 (Home Screen)**
  - [o] UI 레이아웃 구현 (날짜, 원형 차트, 요약 정보)
  - [o] 일일 지출 현황 데이터 연동 및 원형 차트 시각화
  - [o] '오늘의 지출 보기' Bottom Sheet 구현 및 데이터 연동
  - [o] '지출 등록하기' Bottom Sheet 구현
- [] **지출 등록/수정 기능**
  - [o] 지출 등록/수정 폼 위젯 구현 (날짜 선택, 금액/이름 입력, 카테고리 선택)
  - [o] 폼 상태 관리 및 유효성 검사 로직 구현
  - [o] `ExpenseRepository`와 연동하여 데이터 저장/수정
  - [ ] 카테고리 커스텀 기능
- [o] **캘린더 화면 (Calendar Screen)**
  - [o] 캘린더 UI 라이브러리 선정 또는 직접 구현
  - [o] 월별 이동 기능 구현
  - [o] 각 날짜 셀에 총지출액 및 목표 달성 여부 시각화
  - [o] 월간 통계 데이터 표시
  - [o] 날짜 클릭 시 해당일 지출 내역 Bottom Sheet 표시
- [o] **지출 내역 화면 (Expenses List Screen)**
  - [o] 날짜별로 그룹화된 지출 목록 UI 구현

---

## Phase 3: 서비스 연동 및 배포 준비

- [ ] **Firebase 서비스 연동**
  - [ ] `firebase_analytics`를 이용한 화면 조회 및 주요 이벤트 로깅
  - [ ] `google_mobile_ads`를 이용한 배너 광고 등 광고 단위 추가
- [ ] **최적화 및 폴리싱**
  - [ ] 앱 아이콘 및 스플래시 스크린 적용
  - [ ] 성능 프로파일링 및 최적화 (느린 위젯, 불필요한 리빌드 등)
  - [ ] 최종 UI/UX 검토 및 수정
- [ ] **배포 준비**
  - [ ] Google Play Store 및 Apple App Store 등록 준비
  - [ ] 앱 서명(Signing) 설정
  - [ ] 스크린샷 및 앱 설명 자료 준비

---

## Phase 4: 고급 기능 (Post-Launch)

- [ ] **고급 보고서 기능**
- [ ] **월별/카테고리별 예산 설정 기능**
- [ ] **홈 화면 위젯 지원**
- [ ] **자산 관리 기능**
