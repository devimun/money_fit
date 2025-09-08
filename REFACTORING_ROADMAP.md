<!-- @format -->

# 🚀 MoneyFit 리팩토링 로드맵

**문서 버전:** 1.0  
**작성일:** 2025년 1월 27일  
**목표:** 코드 품질 향상, 유지보수성 개선, 재사용성 증대

---

## 📋 리팩토링 원칙

### 1. 단일 책임 원칙 (SRP)

- 각 클래스와 함수는 하나의 명확한 책임만 가져야 함
- 큰 파일을 기능별로 분리

### 2. DRY (Don't Repeat Yourself)

- 중복 코드 제거
- 공통 컴포넌트 추출

### 3. SOLID 원칙 준수

- 개방-폐쇄 원칙 (OCP)
- 의존성 역전 원칙 (DIP)

### 4. 가독성 우선

- 명확한 네이밍
- 적절한 주석과 문서화
- 일관된 코딩 스타일

---

## 🎯 리팩토링 목표

### 단기 목표 (1-2주)

- [ ] 큰 파일들을 기능별로 분리
- [ ] 공통 UI 컴포넌트 추출
- [ ] 다이얼로그 시스템 통합

### 중기 목표 (3-4주)

- [ ] 서비스 레이어 정리
- [ ] 상태 관리 최적화
- [ ] 에러 처리 표준화

### 장기 목표 (1-2개월)

- [ ] 아키텍처 패턴 적용
- [ ] 테스트 코드 추가
- [ ] 성능 최적화

---

## 📊 현재 상태 분석

### 🔴 우선순위 높음 (즉시 처리 필요)

#### 1. ReviewPromptService 분리 (695라인)

**문제점:**

- 여러 다이얼로그가 한 파일에 혼재
- UI 로직과 비즈니스 로직이 섞임

**해결 방안:**

```
lib/core/services/review_prompt_service.dart (비즈니스 로직만)
lib/core/widgets/dialogs/
├── review_dialogs/
│   ├── experience_binary_dialog.dart
│   ├── positive_confirm_dialog.dart
│   ├── negative_feedback_dialog.dart
│   └── thanks_dialog.dart
└── review_dialog_factory.dart
```

**예상 소요시간:** 4-6시간

#### 2. ExpenseAddForm 분리 (501라인)

**문제점:**

- 폼 로직과 카테고리 관리가 혼재
- 다이얼로그 로직이 포함됨

**해결 방안:**

```
lib/core/widgets/forms/
├── expense_add_form.dart (메인 폼)
├── expense_form_fields.dart (필드 컴포넌트들)
└── category_management/
    ├── category_list.dart
    ├── category_dialogs.dart
    └── category_form_helpers.dart
```

**예상 소요시간:** 6-8시간

#### 3. Statistics 화면 분리 (438라인)

**문제점:**

- 화면 로직과 차트 로직이 혼재
- 색상 생성 로직이 복잡함

**해결 방안:**

```
lib/features/statistics/
├── view/
│   └── statistics_screen.dart (메인 화면만)
├── widgets/
│   ├── date_selector.dart
│   ├── category_spending_chart.dart
│   ├── top_expenses_list.dart
│   └── chart_color_generator.dart
└── utils/
    └── chart_helpers.dart
```

**예상 소요시간:** 5-7시간

### 🟡 우선순위 중간 (1-2주 내)

#### 4. AdService 분리 (278라인)

**문제점:**

- 여러 광고 매니저가 한 파일에
- 플랫폼별 로직이 혼재

**해결 방안:**

```
lib/core/services/ads/
├── ad_service.dart (기본 설정)
├── interstitial_ad_manager.dart
├── app_open_ad_manager.dart
├── banner_ad_manager.dart
└── ad_config.dart
```

**예상 소요시간:** 3-4시간

#### 5. HomeViewModel 최적화

**문제점:**

- 여러 계산 로직이 한 클래스에
- 상태 관리가 복잡함

**해결 방안:**

```
lib/features/home/viewmodel/
├── home_view_model.dart (메인)
├── spending_calculator.dart
├── budget_calculator.dart
└── achievement_calculator.dart
```

**예상 소요시간:** 4-5시간

### 🟢 우선순위 낮음 (2-4주 내)

#### 6. 공통 컴포넌트 추출

**대상:**

- 다이얼로그 공통 로직
- 폼 검증 로직
- 색상 테마 로직

**해결 방안:**

```
lib/core/widgets/common/
├── dialogs/
│   ├── base_dialog.dart
│   ├── confirmation_dialog.dart
│   └── input_dialog.dart
├── forms/
│   ├── form_validator.dart
│   └── form_field_builder.dart
└── theme/
    ├── color_extensions.dart
    └── theme_helpers.dart
```

**예상 소요시간:** 6-8시간

---

## 📅 상세 일정표

### Week 1: 핵심 파일 분리

- [ ] **Day 1-2**: ReviewPromptService 분리

  - [ ] 다이얼로그 컴포넌트 추출
  - [ ] 팩토리 패턴 적용
  - [ ] 테스트 및 검증

- [ ] **Day 3-4**: ExpenseAddForm 분리

  - [ ] 폼 필드 컴포넌트 분리
  - [ ] 카테고리 관리 로직 분리
  - [ ] 다이얼로그 로직 분리

- [ ] **Day 5**: Statistics 화면 분리
  - [ ] 차트 컴포넌트 분리
  - [ ] 색상 생성 로직 분리
  - [ ] 유틸리티 함수 분리

### Week 2: 서비스 레이어 정리

- [ ] **Day 1-2**: AdService 분리

  - [ ] 광고 매니저별 분리
  - [ ] 설정 로직 분리
  - [ ] 플랫폼별 로직 정리

- [ ] **Day 3-4**: HomeViewModel 최적화

  - [ ] 계산 로직 분리
  - [ ] 상태 관리 개선
  - [ ] 성능 최적화

- [ ] **Day 5**: 공통 컴포넌트 추출
  - [ ] 다이얼로그 공통 로직
  - [ ] 폼 검증 로직
  - [ ] 테마 헬퍼 함수

### Week 3-4: 품질 향상

- [ ] 에러 처리 표준화
- [ ] 로깅 시스템 개선
- [ ] 코드 문서화
- [ ] 성능 최적화

---

## 🛠️ 리팩토링 체크리스트

### 각 작업 완료 시 확인사항

- [ ] 기능이 정상 작동하는가?
- [ ] 테스트가 통과하는가?
- [ ] 코드 리뷰를 받았는가?
- [ ] 문서가 업데이트되었는가?
- [ ] 진행 상황이 기록되었는가?

### 품질 기준

- [ ] 단일 파일당 300라인 이하
- [ ] 단일 클래스당 200라인 이하
- [ ] 단일 메서드당 50라인 이하
- [ ] 순환 복잡도 10 이하
- [ ] 테스트 커버리지 80% 이상

---

## 📈 진행 상황 추적

### 완료된 작업

- [x] 프로젝트 구조 분석
- [x] 리팩토링 계획 수립
- [ ] ReviewPromptService 분리
- [ ] ExpenseAddForm 분리
- [ ] Statistics 화면 분리
- [ ] AdService 분리
- [ ] HomeViewModel 최적화
- [ ] 공통 컴포넌트 추출

### 현재 진행 중

- [ ] 리팩토링 로드맵 작성

### 다음 단계

- [ ] ReviewPromptService 분리 시작

---

## 🎯 성공 지표

### 정량적 지표

- 평균 파일 크기: 695라인 → 200라인 이하
- 평균 클래스 크기: 300라인 → 150라인 이하
- 코드 중복률: 15% → 5% 이하
- 테스트 커버리지: 0% → 80% 이상

### 정성적 지표

- 코드 가독성 향상
- 유지보수성 개선
- 개발 속도 향상
- 버그 발생률 감소

---

## 📝 참고사항

### 주의사항

- 리팩토링 중 기능 변경 금지
- 각 단계마다 테스트 필수
- 점진적 리팩토링 원칙
- 백업 및 버전 관리 필수

### 도구 및 리소스

- Flutter Inspector
- Dart Analyzer
- 코드 메트릭 도구
- 테스트 프레임워크

---

**마지막 업데이트:** 2025년 1월 27일  
**다음 리뷰 예정일:** 2025년 2월 3일
