<!-- @format -->

# MoneyFit: 종합 개발 명세서

**문서 버전:** 2.1
**최종 수정일:** 2025년 7월 7일

---

## 1. 프로젝트 개요

### 1.1. 프로젝트 목표

MoneyFit은 사용자가 자신의 재정 상태를 직관적으로 파악하고, 건강한 소비 습관을 형성하도록 돕는 것을 목표로 하는 모바일 가계부 애플리케이션입니다. 복잡한 기능 대신, 매일의 지출을 쉽고 빠르게 기록하고 예산 내에서 생활하는 경험에 집중하여 사용자에게 재정 관리의 성공 경험을 제공합니다.

### 1.2. 대상 고객

- 사회초년생 및 대학생: 처음으로 자신의 돈을 관리하며, 쉽고 직관적인 가계부 앱이 필요한 사용자.
- 계획적인 소비를 원하는 20-30대: 월급을 받아 계획적으로 소비하고 싶지만, 기존 가계부 앱의 복잡성에 부담을 느끼는 사용자.
- 재정 상태를 간편하게 파악하고 싶은 모든 사람: 매일의 소비를 기록하고 간단한 피드백을 받기 원하는 사용자.

### 1.3. 핵심 가치 제안

- **Simple & Intuitive:** 직관적인 UI/UX를 통해 누구나 쉽게 지출을 기록하고 예산을 관리����� 수 있습니다.
- **Visual Feedback:** 소비 현황을 원형 차트와 캘린더로 시각화하여 데이터 파악을 용이하게 합니다.
- **Motivation:** 연속 목표 달성일, 월별 통계 등 게임화(Gamification) 요소를 통해 꾸준한 사용을 유도합니다.
- **Offline-First & Scalable:** 초기 버전은 인터넷 연결 없이 모든 기능을 사용할 수 있으며, 향후 클라우드 동기화를 위한 확장 가능한 구조로 설계됩니다.

---

## 2. 기술 스택 및 아키텍처

### 2.1. 플랫폼 및 서비스

- **메인 백엔드 (BaaS):** **Supabase**
  - 역할: 데이터베이스(Postgres), 인증, 스토리지 등 핵심 백엔드 기능 담당. 관계형 데이터 모델의 장점을 활용.
- **부가 서비스:** **Firebase**
  - 역할: 사용자 행동 분석(Analytics), 광고 수익화(AdMob), 푸시 알림(FCM) 등 Google의 강력한 부가 서비스 생태계 활용.

### 2.2. 프론트엔드

- **프레임워크:** Flutter
- **상태 관리:** **Riverpod**
- **주요 의존성:**
  - `supabase_flutter`: Supabase 클라이언트 (인증, DB 연동)
  - `flutter_riverpod`: 상태 관리
  - `uuid`: 클라이언트 측 고유 ID 생성
  - `firebase_core`: Firebase 서비스 연동의 기반
  - `firebase_analytics`: 사용자 행동 분석
  - `google_mobile_ads`: 광고 수익화
  - `sqflite`: (초기 오프라인 버전용) 로컬 데이터베이스 관리
  - `flutter_svg`: SVG 벡터 아이콘 렌더링
  - `intl`: 날짜 및 숫자 포맷팅

### 2.3. 아키텍처 (MVVM + Repository Pattern)

- **Model:** 데이터 구조 정의 (예: `User`, `Expense`, `Category`)
- **View:** UI를 담당하는 위젯
- **ViewModel / StateNotifier:** Riverpod의 `StateNotifier`를 사용하여 View의 상태를 관리하고, 비즈니스 로직을 처리합니다.
- **Repository:** 데이터 소스(로컬 DB, Supabase API)를 추상화하여 ViewModel에 일관된 인터페이스를 제공합니다.
- **인증 및 데이터 흐름 (Supabase 패턴):**
  1.  **앱 최초 실행:** 로컬에 저장된 세션이 없으면, `AuthRepository`는 UUID를 이용해 가짜 이메일/비밀번호를 생성하여 `supabase.auth.signUp()`을 호출합니다.
  2.  **사용자 레코드 생성:** `signUp()` 성공 시, Supabase의 `auth.users` 테이블에 사용자가 생성됩니다. 앱은 반환된 `UID`를 사용하여 `public.users` 테이블에 해당 사용자의 프로필 레코드를 생성합니다.
  3.  **데이터 생성:** 사용자가 지출/카테고리 생성 시, 클라이언트에서 **UUID**로 데이터의 고유 ID를 생성하고, 현재 사용자의 `UID`를 `user_id`로 저장합니다.
  4.  **계�� 연동:** 사용자가 소셜 로그인을 선택하면, `AuthRepository`는 `supabase.auth.updateUser()`를 호출하여 기존 사용자의 이메일을 실제 이메일로 업데이트하고, 필요한 경우 소셜 ID를 연결합니다. 이 과정에서 **`UID`는 변경되지 않아 데이터 연속성이 보장됩니다.**

---

## 3. 데이터 모델 및 DB 스키마

### 3.1. 데이터 모델

#### 3.1.1. 사용자 (User)

| 필드명                  | 데이터 타입 | 설명                                      | 제약 조건                               |
| ----------------------- | ----------- | ----------------------------------------- | --------------------------------------- |
| `id`                    | `TEXT`      | Supabase `auth.users.id` (UID)            | `PRIMARY KEY`                           |
| `email`                 | `TEXT`      | 이메일 주소                               | `NULLABLE`                              |
| `display_name`          | `TEXT`      | 사용자 이름                               | `NULLABLE`                              |
| `daily_budget`          | `REAL`      | 일일 예산 금액                            | `NOT NULL`, `DEFAULT 50000.0`           |
| `is_dark_mode`          | `INTEGER`   | 다크 모드 활성화 여부 (0: false, 1: true) | `NOT NULL`, `DEFAULT 0`                 |
| `notifications_enabled` | `INTEGER`   | 알림 활성화 여부 (0: false, 1: true)      | `NOT NULL`, `DEFAULT 1`                 |
| `created_at`            | `TEXT`      | 생성 시각                                 | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` |
| `updated_at`            | `TEXT`      | 수정 시각                                 | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` |

#### 3.1.2. 지출 (Expense)

| 필드명        | 데이터 타입 | 설명                               | 제약 조건                               |
| ------------- | ----------- | ---------------------------------- | --------------------------------------- |
| `id`          | `TEXT`      | UUID                               | `PRIMARY KEY`                           |
| `user_id`     | `TEXT`      | `User` 모델의 ID (Supabase UID)    | `FOREIGN KEY`                           |
| `name`        | `TEXT`      | 지출명                             | `NOT NULL`                              |
| `amount`      | `REAL`      | 금액                               | `NOT NULL`                              |
| `date`        | `TEXT`      | 지출 날짜 (ISO 8601: "YYYY-MM-DD") | `NOT NULL`                              |
| `category_id` | `TEXT`      | `Category` 모델의 ID (UUID)        | `FOREIGN KEY`                           |
| `type`        | `TEXT`      | 지출 타입 ("필수", "변동")         | `NOT NULL`                              |
| `created_at`  | `TEXT`      | 생성 시각                          | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` |
| `updated_at`  | `TEXT`      | 수정 시각                          | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` |

#### 3.1.3. 카테고리 (Category)

| 필드명         | 데이터 타입 | 설명                                        | 제약 조건                 |
| -------------- | ----------- | ------------------------------------------- | ------------------------- |
| `id`           | `TEXT`      | UUID                                        | `PRIMARY KEY`             |
| `user_id`      | `TEXT`      | `User` 모델의 ID. `NULL`이면 기본 카테고리. | `FOREIGN KEY`, `NULLABLE` |
| `name`         | `TEXT`      | 카테고리명                                  | `NOT NULL`                |
| `type`         | `TEXT`      | 카테고리 타입 ("필수", "변동")              | `NOT NULL`                |
| `is_deletable` | `INTEGER`   | 삭제 가능 여부 (0: false, 1: true)          | `NOT NULL`, `DEFAULT 1`   |

### 3.2. 데이터베이스 스키마 (PostgreSQL - Supabase)

```sql
-- 사용자 프로필 테이블 (public.users)
-- RLS(Row Level Security) 활성화: 사용자는 자신의 정보만 보거나 수정할 수 있음.
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    daily_budget REAL NOT NULL DEFAULT 50000.0,
    is_dark_mode BOOLEAN NOT NULL DEFAULT FALSE,
    notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 카테고리 테이블 (public.categories)
-- RLS 활성화: 사용자는 기본 카테고리와 자신이 만든 카테고리만 볼 수 있음.
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- NULL for default categories
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('필수', '변동')),
    is_deletable BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(user_id, name, type)
);

-- 지출 테이블 (public.expenses)
-- RLS 활성화: 사용자는 자신의 지출 내역만 CRUD 가능.
CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    amount REAL NOT NULL,
    date DATE NOT NULL,
    category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
    type TEXT NOT NULL CHECK(type IN ('필수', '변동')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 기본 카테고리 데이터는 별도의 seed 스크립트로 관리.
-- 예: INSERT INTO public.categories (user_id, name, type, is_deletable) VALUES (NULL, '식비', '필수', FALSE);
```

---

## 4. 기능 명세

### 4.1. 온보딩

- **앱 소개**: 앱의 핵심 가치와 기능을 3단계의 화면으로 나누어 소개합니다.
- **시작하기**: 앱을 시작하는데 있어서 필요한 일일 예산 설정 화면으로 이동합니다..

(기존 명세서 내용과 동일하며, 모든 데이터는 `user_id`와 연결됩니다.)

---

## 5. 비기능적 요구사항

(기존 명세서 내용과 동일)

---

## 6. 향후 로드맵

### Phase 1: MVP (로컬 우선)

- **목표:** Supabase 연동 없이, `sqflite`를 사용하여 오프라인으로 동작하는 앱을 완성합니다. 단, 데이터 모델과 로직은 향후 Supabase 연동을 완벽히 고려하여 설계합니다.
- **주요 과제:**
  - `AuthRepository`는 로컬에서 가짜 사용자 `UID`를 생성하는 로직만 가집니다.
  - `ExpenseRepository` 등은 `sqflite`를 통해 데이터를 CRUD합니다.

### Phase 2: 백엔드 연동 및 정식 출시

- **목표:** Supabase를 실제 백엔드로 연동하고, 데이터를 동기화하며, 정식 계정 시스템을 도입합니다.
- **주요 과제:**
  - `AuthRepository`를 Supabase Auth와 연동하여 실제 익명/소셜 로그인을 구현합니다.
  - `UserRepository`, `ExpenseRepository` 등을 Supabase API와 통신하도록 수정합니다.
  - 로컬 DB에 저장된 데이터를 Supabase로 마이그레이션하는 로직을 구현합니다.
  - Firebase Analytics, AdMob SDK를 연동하여 데이터 수집 및 광고 기능을 활��화합니다.

### Phase 3: 고급 기능 및 서비스 확장

- **목표:** 심층적인 데이터 분석 및 사용자 맞춤형 기능을 제공합니다.
- **주요 과제:**
  - **고급 보고서:** Supabase의 서버리스 함수(Edge Functions)를 이용하여 복잡한 통계 데이터를 계산하고 제공합니다.
  - **예산 계획:** 월별, 카테고리별 예산 설정 기능.
  - **위젯 지원:** 홈 화면에서 오늘 지출 현황을 확인할 수 있는 위젯 제공.
  - **자산 관리:** 현금, 은행 계좌 등 자산 유형을 추가하고 지출과 연동하는 기능.
