# MoneyFit 1.2.7 ASO·스토어 현지화 연구 보고서

- 조사일: **2026-07-21 (Asia/Seoul)**
- 대상 앱: iOS App Store ID `6749416452`, bundle ID / Android package `com.moneyfitapp.app`
- 현재 페이지: [App Store (US, en-US)](https://apps.apple.com/us/app/moneyfit/id6749416452?l=en-US), [Google Play](https://play.google.com/store/apps/details?id=com.moneyfitapp.app&hl=en_US&gl=US)
- 범위: 스토어 검색 결과·경쟁 포지셔닝·공식 정책·현재 Fastlane 메타데이터를 바탕으로 한 **실행 가능한 1.2.7 카피와 출시/측정 계획**. 이 문서는 계획만 다루며 앱 코드나 메타데이터 파일은 변경하지 않는다.

## 0. 결론

최종 영어 승자는 **`MoneyFit - Expense Tracker`**, 한국어 승자는 **`MoneyFit - 하루 예산 가계부`**다. 영어 subtitle은 **`Know what you can spend today`**, 한국어 subtitle은 **`오늘 쓸 수 있는 금액을 한눈에`**로 정한다. `Daily Budget`은 영어로 “하루 예산”이지 “가계부”가 아니다. MoneyFit이 지출을 기록·분류·조회하는 앱이라는 범주를 제목에서 먼저 설명하고, 하루에 안전하게 쓸 수 있는 금액이라는 차별점은 subtitle로 분리한다.

이 조합은 `Money_Fit`처럼 검색 의도를 전혀 설명하지 않는 이름이나, `Your Smart Daily Budget`/`나에게 딱 맞춘 가계부`처럼 차별점이 약한 문구보다 낫다. 제목에는 사전식 직역이 아니라 시장에서 실제 소비자 앱 범주로 쓰이는 표현(`Expense Tracker`, `가계부`, `Control de gastos`, `Haushaltsbuch` 등)을 하나만 붙이고, subtitle/short description에는 MoneyFit의 본질인 **“오늘 얼마를 써도 되는지 한 숫자로 보여준다”**를 배치한다. `smart`, `best`, `#1` 같은 검증 불가능한 수식어는 제거한다.

다만 아래 두 조건은 출시 전 필수다.

1. **상표/브랜드 확인:** `MoneyFit`은 이미 같은 Finance 카테고리에 [MoneyFit by Gold Star](https://apps.apple.com/us/app/moneyfit-by-gold-star/id6458190196)가 있고, 미국에는 `MONEYFIT` 표준문자 상표(등록번호 5,061,051, 금융 서비스)가 검색된다. 한국 Play에도 2026-07-01 출시된 별도 앱 [머니핏 가계부 - 알림 기반 자동 기록](https://play.google.com/store/apps/details?id=com.moavant.moneyfit&hl=ko&gl=KR)이 있다. 이것만으로 침해라고 결론낼 수는 없지만 검색 혼동과 법적 위험이 실제로 있으므로 [USPTO](https://tmsearch.uspto.gov/), [KIPRIS](https://www.kipris.or.kr/khome/main.do), [EUIPO](https://euipo.europa.eu/eSearch/), [WIPO Global Brand Database](https://branddb.wipo.int/)에서 소프트웨어/금융 관련 지정상품까지 확인한 뒤 유지한다. 다른 앱·회사 이름은 keywords에 절대 넣지 않는다.
2. **`offline`/`local data` 주장 보류:** 지출 CRUD는 SQLite(`money_fit.db`)에 저장되지만 첫 사용자 생성은 Supabase 익명 인증을 호출한다. 네트워크 차단 상태의 최초 실행·재실행 테스트를 통과하기 전에는 제목, subtitle, keywords, short description에 `offline`, “완전 로컬”, “로그인 불필요”를 넣지 않는다. 검증 후에는 검색 제목보다 스크린샷/긴 설명의 신뢰 근거로 쓰는 편이 안전하다.

## 1. 조사 방법과 근거 수준

### 1.1 조사 방법

- 공식 한도와 정책은 Apple Developer / Play Console Help의 1차 문서만 기준으로 삼았다.
- 시장 언어는 2026-07-21에 비로그인 웹 환경에서 Apple Search API/App Store 검색과 Google Play 검색을 실제 locale/country로 조회했다. 한 시장당 대표 쿼리 1~2개를 사용하고 노출된 제목·부제·첫 설명의 반복 어휘를 기록했다.
- MoneyFit의 현재 기능·locale·Fastlane 상태는 저장소의 `lib/core/config/locale_config.dart`, `lib/l10n/*.arb`, `ios/fastlane`, `android/fastlane`, iOS/Play 실서비스 페이지를 대조했다.

### 1.2 근거 수준과 한계

| 수준 | 의미 | 이 보고서에서 가능한 결론 |
|---|---|---|
| A | Apple/Google 공식 문서, 실서비스 MoneyFit 페이지, 저장소 원문 | 필드 한도, 정책, 지원 locale, 현재 카피/파일 상태 |
| B | 2026-07-21 비로그인 스토어 검색 결과 | 사용자가 실제로 접하는 어휘와 경쟁 포지셔닝. **검색량은 아님** |
| C | 제목 반복 빈도와 제품 적합성을 이용한 휴리스틱 점수 | 출시 우선순위와 후보 선택. 통계적 승리를 의미하지 않음 |

Apple과 Google은 공개 검색량을 제공하지 않으며 검색 결과는 국가, 기기, 계정, 시점에 따라 달라질 수 있다. 따라서 이 보고서는 `가계부`가 `예산관리`보다 월 검색량이 몇 배라는 식의 수치를 만들지 않는다. 실제 query별 노출/획득은 출시 후 App Store Connect와 Play Console의 자사 데이터로 판정한다. 유료 ASO 도구를 붙일 경우에도 그 수치는 “추정치”로 별도 표기한다.

## 2. 2026-07-21 공식 한도·정책

조회일은 모두 2026-07-21이다.

| 플랫폼/필드 | 공식 한도·정책 | 적용 |
|---|---|---|
| Apple name | 2~30자 | `MoneyFit - 기능어` 전체가 30자 이하여야 한다. 새 버전 또는 편집 가능한 버전 상태에서 변경한다. |
| Apple subtitle | 30자 이하 | 제품 페이지 이름 아래의 한 줄 가치 제안 |
| Apple keywords | **UTF-8 100 bytes 이하**, 각 keyword는 2자를 초과, 앱/회사 이름 중복 불필요, 타사 앱/회사명 금지 | Unicode 글자 수가 아니라 bytes로 CI 검증한다. 쉼표 뒤 공백은 쓰지 않는다. |
| Apple description / promotional text | 4,000자 / 170자 | 설명은 웹 검색에도 사용된다. 본 문서의 최종 카피 범위는 제목·부제·keywords지만 후속 현지화 대상이다. |
| Google app name | 30자 이하 | 전각/반각과 무관하게 30자. 제목은 한 개의 자연스러운 기능어만 사용한다. |
| Google short / full description | 80자 / 4,000자 | short는 핵심 이점 한 줄. 반복 keyword block 금지 |
| 양 스토어 정책 | 오해 유발, 무관·과도한 keyword, 가격/순위/근거 없는 최상급, 타사 상표·관계 암시 금지 | `smartest`, `best`, `free`, `#1`, 타사명, emoji로 순위를 조작하는 제목을 쓰지 않는다. |

1차 출처:

- Apple [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information) — name/subtitle 30자
- Apple [Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information) — keywords 100 bytes, description 4,000자, promotional text 170자
- Apple [App Review Guidelines 2.3.7 / 5.2.1](https://developer.apple.com/app-store/review/guidelines/) — 정확하고 고유한 이름, 관련 keyword, 상표/타사명/무관 문구 금지
- Google [Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en) — title 30자, short 80자, full 4,000자, listing은 track 간 공유
- Google [Best practices for your store listing](https://support.google.com/googleplay/android-developer/answer/13393723?hl=en) 및 [Metadata policy](https://support.google.com/googleplay/android-developer/answer/9898842?hl=en) — 오해 유발·반복·순위/가격·부적절 metadata 금지

## 3. 현재 상태 전수 감사

### 3.1 앱/실서비스 식별

- iOS 실서비스는 `Money_Fit` / `Your Smart Daily Budget`(en-US), `머니핏` / `오늘 쓸 수 있는 금액을 알려줌`(ko), `MoneyFit` / 현지 subtitle(일부 locale)로 노출된다. 앱 내 지원 언어와 별개로 미국 페이지의 binary 언어 표시는 현재 **English and Korean**뿐이다.
- Play 실서비스 기본 title은 `MoneyFit`이고 100+ downloads로 표시된다. package는 `com.moneyfitapp.app`이다.
- 앱 코드의 실제 지원 언어는 `ko,en,es,pl,uk,cs,de,it,ro,sk,bg,id,ms,fil` 총 14개다.

### 3.2 iOS Fastlane

현재 locale 폴더는 12개다.

`cs`, `de-DE`, `en-US`, `es-ES`, `id`, `it`, `ko`, `ms`, `pl`, `ro`, `sk`, `uk`

각 폴더에는 `name`, `subtitle`, `keywords`, `description`, `promotional_text`, `release_notes`, `support_url`, `marketing_url`, `privacy_url`, `apple_tv_privacy_policy` 10개 파일이 모두 있다. 파일 존재는 완전하지만 카피/locale/업로드 상태는 완전하지 않다.

| locale | 현재 name / subtitle | keywords UTF-8 bytes | 판정 |
|---|---|---:|---|
| `en-US` | `Money_Fit` / `Your Smart Daily Budget` | 84 | 제한 내. underscore 제거와 검색 기능어 보강 필요 |
| `ko` | `머니핏` / `오늘 쓸 수 있는 금액을 알려줌` | **146** | **100-byte 초과**. 현재 파일 그대로는 부적합 |
| `es-ES` | `MoneyFit` / `Tu presupuesto diario` | 63 | 제한 내, title 검색 의도 없음 |
| `pl` | `MoneyFit` / `Twój codzienny budżet` | 69 | 제한 내, title 검색 의도 없음 |
| `uk` | `MoneyFit` / `Твій щоденний бюджет` | **110** | **100-byte 초과** |
| `cs` | `MoneyFit` / `Tvůj denní rozpočet` | 60 | 제한 내, title 검색 의도 없음 |
| `de-DE` | `MoneyFit` / `Dein täglicher Budget-Tracker` | 69 | subtitle 29자로 한도에 근접, title 검색 의도 없음 |
| `it` | `MoneyFit` / `Il tuo budget giornaliero` | 55 | 제한 내, title 검색 의도 없음 |
| `ro` | `MoneyFit` / `Bugetul tău zilnic` | 52 | 제한 내, title 검색 의도 없음 |
| `sk` | `MoneyFit` / `Tvoj denný rozpočet` | 60 | 제한 내, title 검색 의도 없음 |
| `id` | `MoneyFit` / `Anggaran harian cerdas` | 79 | 제한 내. `cerdas`보다 구체적 이점 필요 |
| `ms` | `MoneyFit` / `Bajet harian pintar` | 69 | 제한 내. `pintar`보다 구체적 이점 필요 |

추가 문제:

- 앱 언어 14개 중 `bg`, `fil` 폴더가 없다. 그러나 이는 단순 누락만은 아니다. Apple의 [App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-information/app-store-localizations) 50개 목록(2026-03-31 [11개 언어 추가 공지](https://developer.apple.com/news/?id=97t4mt64))에는 **Bulgarian과 Filipino가 없다**. Bulgaria와 Philippines storefront의 기본 metadata 언어는 English (U.K.)다. 따라서 `ios/fastlane/metadata/bg`나 `fil`을 만들면 안 되고, `en-GB` fallback을 추가해야 한다. 아래 표에는 제품 카피 자산으로 두 언어를 제안하되 “ASC 업로드 불가”로 명확히 표시한다.
- iOS 스크린샷 폴더는 `en-US`, `ko`, `id`, `ms` 4개뿐이다. 나머지는 해당 locale 전용 스크린샷이 없다.
- 12개 locale의 `support_url`은 전부 Kakao 오픈채팅, `marketing_url`은 MoneyFit 전용이 아닌 일반 Blogspot, `privacy_url`은 같은 Notion URL이다. Apple은 [Support URL이 실제 연락처로 이어져야 한다](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information)고 명시하므로, 만료 가능한 오픈채팅 대신 이메일·사업자/법정 연락정보·FAQ가 있는 지속 가능한 MoneyFit 지원 페이지로 교체하고 URL 응답/공개 권한을 precheck한다. `apple_tv_privacy_policy.txt`는 12개 locale 모두 사실상 비어 있다. iPhone-only 앱의 legacy 파일이라면 삭제/미사용으로 표준화해 공백 파일을 필드 값으로 오인하지 않게 한다.
- 현재 긴 설명에는 `smartest`, `más inteligente`, `najinteligentniejszą`, `найрозумнішим` 등 근거 없는 최상급이 여러 locale에 남아 있다. title/short만 바꾸고 끝내지 말고 1.2.7 description/full_description에서도 이를 “simple/clear” 같은 검증 가능한 설명으로 제거한다. `Intelligent Analysis`처럼 실제 기능명에 가까운 일반 형용사와 “가장 똑똑한 앱”이라는 비교 최상급은 구분한다.
- `ios/Runner`의 binary localization은 `en.lproj/InfoPlist.strings`, `ko.lproj/InfoPlist.strings`뿐이고 Xcode `knownRegions`도 `en`, `Base`, `ko`다. `CFBundleLocalizations`도 없다. Flutter ARB 14개와 ASC metadata 폴더 추가만으로 App Store의 “Languages”가 14개로 바뀐다고 단정할 수 없다. Archive의 최종 `Runner.app/Info.plist`와 App Store Connect의 binary localization 인식을 별도로 확인해야 한다.
- `update_metadata` lane은 이미 metadata-only 구조이나 `force: true`여서 Fastlane HTML preview 확인을 건너뛴다.

### 3.3 Android Fastlane

현재 폴더는 `bg`, `cs-CZ`, `de-DE`, `en-US`, `es-ES`, `id`, `it-IT`, `ko-KR`, `ms`, `ms-MY`, `pl-PL`, `ro`, `sk`, `uk` 총 14개다. 각 폴더에 title/short/full/changelog와 7개 phone screenshot이 존재한다.

그러나 언어 커버리지는 14개가 아니다.

- `ms`와 공식 Play locale `ms-MY`가 같은 text/asset을 중복 보관한다.
- 실제 지원 언어 `fil`은 빠져 있다. Google의 [지원 번역 locale 목록](https://support.google.com/googleplay/android-developer/answer/9844778?hl=en)에는 `fil`과 `ms-MY`가 있으므로 **`ms`를 제거·`ms-MY`로 단일화하고 `fil`을 추가**한다.
- 다수 locale의 screenshot 파일명이 `*_en-US.png`여서 영어 자산을 재사용한 것으로 보인다. 업로드 전 실제 이미지 문구를 눈으로 확인하고, 적어도 1차 시장 `ko-KR`, `en-US`, `es-ES`, `pl-PL`, `uk`, `cs-CZ`는 현지화한다.
- 모든 locale의 `video.txt`가 비어 있다. 의도적으로 promo video가 없다면 정상이나, 공백 파일을 업로드 대상으로 취급하지 않도록 validation에서 “선택 필드 empty는 경고 또는 제거” 규칙을 둔다. title/short/full/changelog는 전 locale에 모두 존재한다.
- `android/fastlane/Appfile`의 JSON key 절대경로가 현재 workspace가 아닌 `/Users/jun/Desktop/money_fit/...`를 가리킨다. 환경변수/저장소 상대경로로 교정하기 전 lane이 실패할 수 있다.
- 현재 로컬 Bundler 환경에서 `bundle exec fastlane`은 lockfile의 gem을 찾지 못한다. `bundle install`로 `Gemfile.lock`과 일치시키는 것이 metadata 배포 전제다.

현재 한국 Android short description은:

> 머니핏은 ‘오늘 얼마까지 써도 괜찮을까?’라는 질문에 명확한 숫자로 답해주는 심플한 예산 관리 서비스입니다.

Unicode **60자**, UTF-8 **152 bytes**다. Google은 80 **characters** 제한이므로 **초과하지 않는다**. bytes를 잘못 적용해 초과라고 판단하면 안 된다. 현재 다른 Android title/short도 각각 30/80자 이내다.

## 4. 시장·경쟁 포지셔닝 연구

### 4.1 핵심 시장

| 시장 | 2026-07-21 실제 관찰 | MoneyFit 결정 |
|---|---|---|
| 미국 | 일반 결과는 `Expense Tracker`, `Budget Planner`, `Spending Tracker`가 제목에 반복된다. [Expense: Budget Tracker](https://apps.apple.com/us/app/expense-budget-tracker/id1669548999), [Expense Tracker: Budget Planner](https://apps.apple.com/us/app/expense-tracker-budget-planner/id944934437), [Expense Tracker - Money Note](https://apps.apple.com/us/app/expense-tracker-money-note/id1320730220)처럼 소비자용 “가계부” 범주는 `Account Book`이 아니라 `Expense Tracker`로 표현된다. `Daily Budget`은 [Spendaily](https://apps.apple.com/us/app/spendaily-daily-budget/id6757773714), [DaySpend](https://apps.apple.com/us/app/daily-budget-dayspend/id6761328061)처럼 하루 예산 계산이라는 더 좁은 기능어다. | 제목 `Expense Tracker`로 앱 범주를 잡고 subtitle `Know what you can spend today`로 MoneyFit의 하루 예산 차별점을 설명한다. `Account Book` 직역은 쓰지 않는다. |
| 한국 | [위플 가계부](https://apps.apple.com/kr/app/id467936485), [편한가계부](https://apps.apple.com/kr/app/id560481810), [꼬박가계부](https://apps.apple.com/kr/app/id6460690098) 등 `가계부`가 대표 카테고리어이고, 경쟁 제목에는 `지출관리`, `저축`, `예산관리`가 보조어로 붙는다. | 브랜드는 로마자 `MoneyFit`로 통일해 동명 `머니핏 가계부`와 시각적으로 구분하고 `하루 예산 가계부`로 범주+차별점을 동시에 설명한다. |
| 스페인 | `Gestor de gastos`, `Control de gastos`, `presupuesto`가 반복된다. 예: [Monefy: Control de gastos](https://apps.apple.com/es/app/monefy-control-de-gastos/id1212024409), [Control de Gastos - Soldi](https://apps.apple.com/es/app/control-de-gastos-soldi/id6739777905). | 제목 `Control de gastos`, subtitle `presupuesto diario`. |
| 폴란드 | Play 결과에 `wydatki i budżet`, `kontrola wydatków`, `finanse`가 반복된다. App Store 검색은 영어 제목 비중도 높아 locale별 최적화 여지가 있다. | 제목 `Kontrola wydatków`, subtitle `budżet dzienny`. |
| 우크라이나 | Play 결과에 `облік витрат`, `трекер бюджету`, `гроші`가 반복된다. 예: [Money Tracker](https://play.google.com/store/apps/details?id=com.freeman.moneymanager&hl=uk&gl=UA), [Fast Budget](https://play.google.com/store/apps/details?id=com.blodhgard.easybudget&hl=uk&gl=UA). | 제목 `Облік витрат`, subtitle `щоденний бюджет`. Cyrillic은 Apple byte 한도가 빨리 차므로 keyword를 짧게 유지한다. |
| 체코 | Play 결과의 `Správa financí`, `Výdaje`, `Rozpočet`, `sledování`가 기능 인식어다. iOS 결과는 영어 title 비중이 높다. | 제목 `Sledování výdajů`, subtitle `denní rozpočet`. |

### 4.2 확장 시장

| 시장 | 2026-07-21 실제 관찰 | MoneyFit 결정 |
|---|---|---|
| 독일 | [Haushaltsbuch Ausgaben Monee](https://apps.apple.com/de/app/haushaltsbuch-ausgaben-monee/id1617877213) 등 `Haushaltsbuch`가 강하게 반복되고 `Ausgaben`, `Budget`가 보조한다. | 제목 `Haushaltsbuch`, subtitle `Tagesbudget`. |
| 이탈리아 | [Monefy - Gestione spese](https://apps.apple.com/it/app/monefy-gestione-spese/id1212024409) 등 `Gestione spese`, `budget`, `finanze`가 반복된다. | 제목 `Gestione spese`, subtitle `budget giornaliero`. |
| 루마니아 | [Money - Buget & Cheltuieli](https://apps.apple.com/ro/app/money-buget-cheltuieli/id1185488696?l=ro), [Buget și monitor de cheltuieli](https://apps.apple.com/ro/app/buget-%C8%99i-monitor-de-cheltuieli/id1584657093?l=ro)처럼 `buget`과 `cheltuieli`가 함께 반복된다. 단순 `Buget personal`보다 실제 기록 기능까지 드러난다. | 제목 `Buget și cheltuieli`, subtitle에 “오늘 얼마”를 직접 표현한다. |
| 슬로바키아 | [Many: Výdavky & Rozpočet](https://apps.apple.com/sk/app/many-v%C3%BDdavky-rozpo%C4%8Det/id1591968342?l=sk), [Money - Rozpočet & Výdavky](https://apps.apple.com/sk/app/money-personal-finance-app/id1185488696?l=sk), [Správca Financií - výdavky](https://apps.apple.com/sk/app/spr%C3%A1vca-financi%C3%AD-v%C3%BDdavky/id6444122615?l=sk)에서 `výdavky`와 `rozpočet`이 반복된다. | 제목 `Výdavky a rozpočet`, subtitle에 오늘 쓸 수 있는 금액을 배치한다. |
| 불가리아 | Apple은 불가리아어 metadata를 지원하지 않는다. Play 결과는 [Приходи и разходи](https://play.google.com/store/apps/details?hl=bg&id=com.mg.wydatki), [Бюджет и следене на разходи](https://play.google.com/store/apps/details?hl=bg&id=money.manager.expense.tracker.budget.finance.wallet)처럼 `разходи`와 `бюджет` 중심이다. | Play `Разходи и бюджет`; iOS는 `en-GB` fallback. 불가리아어 iOS 카피는 향후 Apple 지원/광고 자산용으로 보관한다. |
| 인도네시아 | [MoneyTrack - Catatan Keuangan](https://apps.apple.com/id/app/moneytrack-catatan-keuangan/id1473785373?l=id), [Catatku: Catatan Keuangan](https://apps.apple.com/id/app/catatku-catatan-keuangan/id6755680087?l=id), [Catatan pengeluaran - Mona AI](https://apps.apple.com/id/app/catatan-pengeluaran-mona-ai/id6743129895?l=id)처럼 `Catatan Keuangan`과 `catatan pengeluaran`이 반복된다. | 제목 `Catatan Keuangan`, subtitle에 오늘의 소비 한도를 명시한다. |
| 말레이시아 | [Belanja - Rekod Perbelanjaan](https://apps.apple.com/my/app/belanja-rekod-perbelanjaan/id1401126213?l=ms), [MoneyTrack - Rekod Belanja](https://apps.apple.com/my/app/moneytrack-rekod-belanja/id1473785373?l=ms)처럼 `Rekod Perbelanjaan`/`Rekod Belanja`가 실제 소비자 앱 제목에 쓰인다. | `Rekod Perbelanjaan` + `Bajet harian`으로 범주와 차별점을 나눈다. |
| 필리핀 | `budget tracker` 검색 결과는 거의 영어이고, `budget at gastos`/`badyet araw-araw`에서는 `Gastos`, `Pera`, `Matalinong Gastos` 같은 Taglish/Filipino 표현이 나타난다. Apple은 Filipino metadata를 지원하지 않는다. | Play는 `Budget at Gastos`로 영어 검색 의도와 현지 이해를 함께 잡는다. iOS는 `en-GB` fallback을 쓴다. |

검색 재현 링크: [US App Store](https://apps.apple.com/us/search?term=daily%20budget), [US Play](https://play.google.com/store/search?q=daily%20budget&c=apps&hl=en_US&gl=US), [KR App Store](https://apps.apple.com/kr/search?term=%EA%B0%80%EA%B3%84%EB%B6%80), [KR Play](https://play.google.com/store/search?q=%EA%B0%80%EA%B3%84%EB%B6%80&c=apps&hl=ko&gl=KR), [ES Play](https://play.google.com/store/search?q=control%20de%20gastos&c=apps&hl=es&gl=ES), [PL Play](https://play.google.com/store/search?q=kontrola%20wydatk%C3%B3w&c=apps&hl=pl&gl=PL), [UA Play](https://play.google.com/store/search?q=%D0%BE%D0%B1%D0%BB%D1%96%D0%BA%20%D0%B2%D0%B8%D1%82%D1%80%D0%B0%D1%82&c=apps&hl=uk&gl=UA), [CZ Play](https://play.google.com/store/search?q=sledov%C3%A1n%C3%AD%20v%C3%BDdaj%C5%AF&c=apps&hl=cs&gl=CZ), [DE Play](https://play.google.com/store/search?q=Haushaltsbuch&c=apps&hl=de&gl=DE), [IT Play](https://play.google.com/store/search?q=gestione%20spese&c=apps&hl=it&gl=IT), [RO Play](https://play.google.com/store/search?q=eviden%C8%9Ba%20cheltuielilor&c=apps&hl=ro&gl=RO), [SK Play](https://play.google.com/store/search?q=sledovanie%20v%C3%BDdavkov&c=apps&hl=sk&gl=SK), [BG Play](https://play.google.com/store/search?q=%D0%BF%D1%80%D0%BE%D1%81%D0%BB%D0%B5%D0%B4%D1%8F%D0%B2%D0%B0%D0%BD%D0%B5%20%D0%BD%D0%B0%20%D1%80%D0%B0%D0%B7%D1%85%D0%BE%D0%B4%D0%B8&c=apps&hl=bg&gl=BG), [ID Play](https://play.google.com/store/search?q=pencatat%20keuangan&c=apps&hl=id&gl=ID), [MY Play](https://play.google.com/store/search?q=rekod%20perbelanjaan&c=apps&hl=ms&gl=MY), [PH Play](https://play.google.com/store/search?q=budget%20at%20gastos&c=apps&hl=fil&gl=PH).

## 5. 후보 비교와 최종 승자

점수는 공개 검색량이 아니라 `검색 의도 35 + 차별점 30 + 즉시 이해/현지화 20 + 브랜드·간결성 15`의 내부 휴리스틱이다.

| 영어 후보 | 검색 의도 | 차별점 | 이해 | 브랜드/간결 | 합계 | 판정 |
|---|---:|---:|---:|---:|---:|---|
| `MoneyFit - Expense Tracker` | 35 | 18 | 20 | 14 | **87** | **승자**. 영어권 소비자용 가계부의 대표 범주어. 차별점은 subtitle로 보완 |
| `MoneyFit - Daily Budget` | 31 | 26 | 19 | 10 | 86 | 제품 핵심은 잘 드러나지만 “가계부”가 아니라 하루 예산 계산 기능만 뜻함 |
| `MoneyFit - Safe to Spend` | 22 | 30 | 16 | 15 | 83 | 차별적이지만 낯선 표현이고 직접 경쟁이 이미 사용 |
| `MoneyFit - Budget & Expenses` | 34 | 17 | 18 | 12 | 81 | 무난하지만 keyword 나열 인상이 강함 |

| 한국어 후보 | 검색 의도 | 차별점 | 이해 | 브랜드/간결 | 합계 | 판정 |
|---|---:|---:|---:|---:|---:|---|
| `MoneyFit - 하루 예산 가계부` | 34 | 28 | 20 | 14 | **96** | **승자**. `가계부`와 “하루”를 동시에 전달 |
| `MoneyFit - 간편 가계부` | 35 | 17 | 20 | 15 | 87 | 대표 검색어는 좋지만 차별점 약함 |
| `MoneyFit - 오늘의 지출한도` | 23 | 30 | 18 | 14 | 85 | 기능은 정확하나 가계부 앱인지 바로 알기 어려움 |

`MoneyFit - ??` 구조는 유지하되 모든 언어에 `가계부`를 사전식으로 직역하지 않는다. 브랜드 `MoneyFit`은 동일하게 유지하고 하이픈 뒤는 시장에서 자연스럽게 쓰는 대표 범주어로 현지화한다.

- 일상 명사가 곧 앱 범주어인 시장: 한국 `가계부`, 독일 `Haushaltsbuch`, 인도네시아 `Catatan Keuangan`, 말레이시아 `Rekod Perbelanjaan`
- 기능형 표현이 자연스러운 시장: 영어 `Expense Tracker`, 스페인어 `Control de gastos`, 폴란드어 `Kontrola wydatków`, 우크라이나어 `Облік витрат`, 체코어 `Sledování výdajů`, 이탈리아어 `Gestione spese`
- 예산과 지출을 함께 써야 범주가 선명한 시장: 루마니아어 `Buget și cheltuieli`, 슬로바키아어 `Výdavky a rozpočet`, 불가리아어 `Разходи и бюджет`, Filipino `Budget at Gastos`

영어 `Account Book`, 스페인어 `libro de cuentas`, 이탈리아어 `libro contabile` 같은 직역은 개인 금융 앱보다 장부·회계 문맥으로 들리므로 제목에서 제외한다. 제목에 현지 범주어, subtitle/short에 “오늘 쓸 수 있는 금액”, 긴 설명/스크린샷에 simple·daily/monthly·local storage 검증 사실을 배치하는 계층이 가장 균형 잡힌다.

## 6. iOS 최종 카피 세트

글자 수는 Unicode code point 기준, keyword는 UTF-8 byte 기준으로 스크립트 검증했다. emoji/결합문자를 쓰지 않아 사용자 지각 문자와의 차이도 피했다. 모두 name/subtitle 30자, keywords 100 bytes 이내다.

| 앱 언어 | ASC/Fastlane locale | 최종 name (글자) | 최종 subtitle (글자) | 최종 keywords (UTF-8 bytes) |
|---|---|---|---|---|
| en | `en-US` | `MoneyFit - Expense Tracker` (26) | `Know what you can spend today` (29) | `budget,spending,planner,money,savings,finance,calendar,simple,daily` (67B) |
| ko | `ko` | `MoneyFit - 하루 예산 가계부` (20) | `오늘 쓸 수 있는 금액을 한눈에` (17) | `지출관리,소비습관,돈관리,월예산,소비분석,용돈기입장` (74B) |
| es | `es-ES` | `MoneyFit - Control de gastos` (28) | `Tu presupuesto diario simple` (28) | `dinero,finanzas,ahorro,gestor,límite,mensual,seguimiento,calendario` (68B) |
| pl | `pl` | `MoneyFit - Kontrola wydatków` (28) | `Twój prosty budżet dzienny` (26) | `finanse,pieniądze,oszczędności,limity,miesięczny,rejestr,portfel,kalendarz` (78B) |
| uk | `uk` | `MoneyFit - Облік витрат` (23) | `Твій простий щоденний бюджет` (28) | `фінанси,гроші,економія,ліміт,гаманець,місячний` (87B) |
| cs | `cs` | `MoneyFit - Sledování výdajů` (27) | `Jednoduchý denní rozpočet` (25) | `finance,peníze,úspory,limit,měsíční,evidence,kalendář` (61B) |
| de | `de-DE` | `MoneyFit - Haushaltsbuch` (24) | `Dein einfaches Tagesbudget` (26) | `ausgaben,tracker,finanzen,geld,sparen,limit,monatlich,kalender` (62B) |
| it | `it` | `MoneyFit - Gestione spese` (25) | `Il tuo budget giornaliero` (25) | `soldi,finanze,risparmio,limite,mensile,registro,semplice,calendario` (67B) |
| ro | `ro` | `MoneyFit - Buget și cheltuieli` (30) | `Vezi cât poți cheltui azi` (25) | `bani,finanțe,economii,zilnic,lunar,monitorizare,simplu,personal` (64B) |
| sk | `sk` | `MoneyFit - Výdavky a rozpočet` (29) | `Koľko môžeš dnes minúť` (22) | `financie,peniaze,úspory,denný,mesačný,sledovanie,kalendár,osobný` (70B) |
| bg | **ASC 미지원** | `MoneyFit - Разходи и бюджет` (27) | `Колко можеш да похарчиш днес` (28) | `пари,финанси,спестяване,дневен,месечен,личен` (83B) |
| id | `id` | `MoneyFit - Catatan Keuangan` (27) | `Tahu batas belanja hari ini` (27) | `anggaran,pengeluaran,uang,hemat,tabungan,harian,bulanan,pencatat,kalender` (73B) |
| ms | `ms` | `MoneyFit - Rekod Perbelanjaan` (29) | `Bajet harian yang ringkas` (25) | `kewangan,wang,simpanan,had,bulanan,jejak,jimat,kalendar` (55B) |
| fil | **ASC 미지원** | `MoneyFit - Budget at Gastos` (27) | `Budget mo para sa araw na ito` (29) | `pera,ipon,tracker,araw-araw,badyet,tipid,limit,talaan` (53B) |

`bg`와 `fil` 행은 14개 제품 언어의 최종 용어집/향후 Apple 지원/마케팅 자산용이지 현재 ASC에 업로드할 locale이 아니다. 실제 iOS Bulgaria/Philippines에는 다음 `en-GB` fallback을 추가한다.

```text
ios/fastlane/metadata/en-GB/name.txt
MoneyFit - Expense Tracker

ios/fastlane/metadata/en-GB/subtitle.txt
Know what you can spend today

ios/fastlane/metadata/en-GB/keywords.txt
budget,spending,planner,money,savings,finance,calendar,simple,daily
```

## 7. Android 최종 카피 세트

Google 한도는 bytes가 아닌 characters다. title/short 모두 각각 30/80자 이내로 검증했다.

| 앱 언어 | Fastlane locale | 최종 title (글자) | 최종 short_description (글자) |
|---|---|---|---|
| en | `en-US` | `MoneyFit - Expense Tracker` (26) | `See exactly how much you can safely spend today. Simple daily budget.` (69) |
| ko | `ko-KR` | `MoneyFit - 하루 예산 가계부` (20) | `오늘 얼마까지 써도 되는지 바로 확인하는 심플한 하루 예산 가계부` (36) |
| es | `es-ES` | `MoneyFit - Control de gastos` (28) | `Descubre cuánto puedes gastar hoy con un presupuesto diario simple.` (67) |
| pl | `pl-PL` | `MoneyFit - Kontrola wydatków` (28) | `Sprawdź, ile możesz dziś wydać. Prosty budżet dzienny i kontrola wydatków.` (74) |
| uk | `uk` | `MoneyFit - Облік витрат` (23) | `Дізнайся, скільки можна витратити сьогодні. Простий щоденний бюджет.` (68) |
| cs | `cs-CZ` | `MoneyFit - Sledování výdajů` (27) | `Hned víš, kolik můžeš dnes utratit. Jednoduchý denní rozpočet.` (62) |
| de | `de-DE` | `MoneyFit - Haushaltsbuch` (24) | `Sieh sofort, wie viel du heute ausgeben kannst. Einfaches Tagesbudget.` (70) |
| it | `it-IT` | `MoneyFit - Gestione spese` (25) | `Scopri quanto puoi spendere oggi con un budget giornaliero semplice.` (68) |
| ro | `ro` | `MoneyFit - Buget și cheltuieli` (30) | `Vezi cât poți cheltui azi. Buget zilnic simplu și evidența cheltuielilor.` (73) |
| sk | `sk` | `MoneyFit - Výdavky a rozpočet` (29) | `Hneď vieš, koľko môžeš dnes minúť. Jednoduchý denný rozpočet.` (61) |
| bg | `bg` | `MoneyFit - Разходи и бюджет` (27) | `Виж колко можеш да похарчиш днес. Лесен дневен бюджет и следене на разходи.` (75) |
| id | `id` | `MoneyFit - Catatan Keuangan` (27) | `Cek berapa yang aman dibelanjakan hari ini. Anggaran harian yang simpel.` (72) |
| ms | `ms-MY` | `MoneyFit - Rekod Perbelanjaan` (29) | `Tahu jumlah yang boleh dibelanja hari ini. Bajet harian yang ringkas.` (69) |
| fil | `fil` | `MoneyFit - Budget at Gastos` (27) | `Alamin kung magkano ang puwedeng gastusin ngayon. Simpleng budget araw-araw.` (76) |

현지 표현은 각 시장의 실제 검색 제목에 반복된 범주어를 기준으로 잡았고 영어 문장을 단어 대 단어 번역하지 않았다. 그래도 제목은 장기간 고정되고 정책 심사를 받으므로 `es/pl/uk/cs/de/it/ro/sk/bg/id/ms/fil`은 출시 직전 각 1명의 현지 원어민에게 “자연스러움, 존대 일관성, 금융 의미, 30/80자 유지”만 최종 교정받는다. 원어민이 단어를 바꾸면 같은 validation을 다시 실행한다.

## 8. 파일 매핑과 구현 순서

| 앱 언어 | iOS Fastlane | Android Fastlane | 조치 |
|---|---|---|---|
| en | `en-US` + 신규 `en-GB` | `en-US` | US와 BG/PH fallback 분리 |
| ko | `ko` | `ko-KR` | 양쪽 교체 |
| es | `es-ES` | `es-ES` | 양쪽 교체 |
| pl | `pl` | `pl-PL` | 양쪽 교체 |
| uk | `uk` | `uk` | 양쪽 교체, keywords byte 수정 |
| cs | `cs` | `cs-CZ` | 양쪽 교체 |
| de | `de-DE` | `de-DE` | 양쪽 교체 |
| it | `it` | `it-IT` | 양쪽 교체 |
| ro | `ro` | `ro` | 양쪽 교체 |
| sk | `sk` | `sk` | 양쪽 교체 |
| bg | 없음(Apple 미지원) | `bg` | iOS는 `en-GB`, Play만 현지 카피 |
| id | `id` | `id` | 양쪽 교체 |
| ms | `ms` | `ms-MY` | Android `ms` 중복 제거 |
| fil | 없음(Apple 미지원) | 신규 `fil` | iOS는 `en-GB`, Play에 신규 추가 |

구현 순서:

1. 브랜드/상표 clearance 결과를 기록하고 `MoneyFit` 유지 여부를 확정한다. 보류라면 **어떤 metadata도 업로드하지 않는다**.
2. App Store Connect에서 현재 primary language, 13개 실제 metadata localization(en-GB 포함), 1.2.7 draft 상태를 확인한다. `fastlane deliver download_metadata`를 별도 임시 폴더에 내려 받아 로컬과 diff하고 서버 쪽 최신 변경을 덮어쓰지 않는다.
3. iOS binary에 14개 앱 언어가 인식되도록 Xcode localization/`CFBundleLocalizations` 전략을 확정한다. Archive 후 최종 `Runner.app/Info.plist`의 localization을 확인하고 TestFlight 각 언어에서 display name, 앱 내부 문자열을 확인한다. **ASC metadata localization과 binary의 “Languages” 표시는 별개 검증 항목**이다.
4. 위 표대로 `name.txt`, `subtitle.txt`, `keywords.txt`, `title.txt`, `short_description.txt`를 적용하고 Android `ms`를 `ms-MY`로 단일화, `fil`을 추가한다. iOS에는 `bg`/`fil`을 만들지 않는다.
5. 12개 비한/영어권 카피를 원어민 검수하고, title과 short뿐 아니라 긴 설명 첫 3문장 및 첫 3개 screenshot headline도 같은 용어집으로 맞춘다. Google은 긴 설명도 검색에 쓰이므로 자연문 속에 대표어를 1~2회만 넣고 keyword block을 만들지 않는다.
6. 자동 validation → Fastlane preview/validate → 콘솔 draft 확인 → 단계적 publish 순서로 진행한다.

## 9. 자동 validation과 metadata-only lane

### 9.1 로컬 validation

`tool/validate_store_metadata.dart` 또는 `scripts/validate_store_metadata.rb`를 추가해 CI와 lane 앞에서 다음을 실패 조건으로 검사한다.

- iOS `name.length` 2~30, `subtitle.length <= 30`, `keywords.bytesize <= 100`
- Android `title.length <= 30`, `short_description.length <= 80`
- 앞뒤 공백·개행 정리, keyword 쉼표 뒤 공백/빈 token/중복 token 금지
- `MoneyFit`/name/subtitle에 이미 있는 단어를 iOS keywords에서 중복 사용하지 않는지 경고
- 금칙어: `best`, `#1`, `free`, 경쟁사명, 가격/할인, 검증 전 `offline`, `no login`, `100% private`
- 앱 지원 언어 집합과 store locale mapping 일치. Android `ms` 중복 및 `fil` 누락, iOS의 미지원 `bg`/`fil` 폴더를 오류로 처리
- 결과를 `locale, field, Unicode chars, UTF-8 bytes, limit` CSV/Markdown으로 출력해 PR에 남김

### 9.2 iOS lane

현재 `update_metadata`의 metadata-only 성격은 유지하되 `force: true`를 제거해 HTML preview를 확인하고, 제출 lane에서는 `precheck_default_rule_level: :error`를 사용한다. Fastlane의 [deliver 문서](https://docs.fastlane.tools/actions/appstore/)상 `force`는 preview 검증을 건너뛰며, [precheck](https://docs.fastlane.tools/actions/precheck/)는 ASC metadata의 상표/placeholder/URL 등 흔한 문제를 검사한다.

권장 분리:

```ruby
lane :preview_metadata do
  sh("dart run tool/validate_store_metadata.dart")
  deliver(
    submit_for_review: false,
    skip_binary_upload: true,
    skip_screenshots: true,
    skip_metadata: false,
    force: false
  )
end

lane :update_metadata do
  sh("dart run tool/validate_store_metadata.dart")
  deliver(
    submit_for_review: false,
    skip_binary_upload: true,
    skip_screenshots: true,
    skip_metadata: false,
    precheck_default_rule_level: :error
  )
end
```

Apple name은 live 상태에서 즉시 바꾸는 필드가 아니다. 1.2.7의 편집 가능한 version metadata에 올리고 새 버전 심사와 함께 반영한다. metadata-only lane이 성공해도 live name 변경 완료로 간주하지 말고, App Review 승인 후 storefront를 locale별로 재검증한다.

### 9.3 Android lane

JSON key 절대경로를 `SUPPLY_JSON_KEY` 같은 환경변수로 바꾸고, Fastlane [supply `validate_only`](https://docs.fastlane.tools/actions/supply/)를 먼저 실행한다.

```ruby
lane :validate_metadata do
  sh("dart run tool/validate_store_metadata.dart")
  upload_to_play_store(
    validate_only: true,
    skip_upload_aab: true,
    skip_upload_images: true,
    skip_upload_screenshots: true,
    skip_upload_metadata: false,
    skip_upload_changelogs: true
  )
end
```

`validate_only` 성공 뒤 기존 `update_metadata`를 실행한다. Google 기본 store listing은 track 간 공유되므로 `internal`이라는 이름만 보고 내부 사용자에게만 보인다고 생각하면 안 된다. publish 전 Play Console의 Managed publishing 상태와 변경사항 목록을 확인한다.

## 10. 단계적 출시·실험·측정

### 10.1 baseline

변경 직전 28일을 고정 baseline으로 CSV export한다. 설치 수가 100+ 수준이므로 일 단위 변동 대신 locale/국가별 28일 합계를 쓴다.

- Apple: [Acquisition](https://developer.apple.com/help/app-store-connect-analytics/acquisition/acquisition)에서 App Store Search로 필터한 `Unique Impressions → Unique Product Page Views → First-Time Downloads`, conversion rate, territory
- Google: [Store performance / Conversion analysis](https://support.google.com/googleplay/android-developer/answer/9859173?hl=en)에서 `Store listing visitors → Acquisitions → Conversion rate`, traffic source=Google Play search, country, language, query(제공되는 범위)
- 품질 guardrail: 첫 실행 완료율, 예산 설정 완료율, D1/D7 retention, crash-free users, uninstall rate. ASO로 저의도 유입만 늘어나는지 확인한다.

계산식:

```text
Search tap-through = product page views / search impressions       (Apple)
Store conversion   = first-time downloads / product page views    (Apple)
Store conversion   = acquisitions / store listing visitors        (Play)
End-to-end yield   = downloads(or acquisitions) / impressions(or search visitors)
```

### 10.2 실험 수단의 정확한 한계

- Apple [Product Page Optimization](https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/overview-of-product-page-optimization)은 최대 3개 treatment의 **icon, screenshots, preview**를 시험한다. name/subtitle/keywords A/B 도구가 아니다. 결과는 최소 5 first-time downloads부터 나타나며 90% confidence 판정을 제공하지만, 저트래픽 앱에서는 90일 안에도 inconclusive일 수 있다.
- 따라서 Apple title/subtitle은 전후/territory cohort로 측정한다. PPO는 새 카피와 맞춘 첫 screenshot headline A안(“Know what you can spend today”) 대 B안(“One clear daily budget”)을 시험한다.
- Google [Store listing experiments 공식 도움말](https://support.google.com/googleplay/android-developer/answer/12053285?hl=en)은 default graphics experiment에서 icon/feature graphic/screenshots/video, localized experiment에서 같은 graphic과 **short/full description만** 시험할 수 있다고 명시한다. **app title은 시험 대상이 아니다.** 따라서 이 보고서의 title은 Apple과 마찬가지로 단계적 전후 비교로 측정하고, Play A/B는 위 최종 short description과 screenshot message-match를 검증하는 데 쓴다. 비로그인 Play 사용자는 experiment variant를 보지 않는다는 공식 제한도 결과 해석에 기록한다.
- Google [Custom Store Listings](https://support.google.com/googleplay/android-developer/answer/9867158?hl=en)은 country 및 가능한 경우 search keyword segment별로 name/description/assets를 다르게 만들 수 있다. 이는 무작위 A/B가 아니므로 실험 결과와 혼동하지 않는다. `daily budget` 고의도 유입용 페이지와 `expense tracker` 일반 유입용 페이지의 message-match를 비교하는 보조 수단으로 사용한다.

### 10.3 출시 순서와 판단 규칙

1. **T-28~T-1:** baseline 고정, 상표 clearance, native QA, validation/preview, screenshot headline 제작.
2. **iOS 1.2.7:** Apple name은 version 심사가 필요한 필드이므로 12개 지원 metadata locale + `en-GB`를 한 번에 1.2.7 심사에 넣고 territory별로 전후 비교한다. Apple metadata를 Play처럼 live에서 locale별 순차 publish할 수 있다고 가정하지 않는다. 꼭 위험을 나누려면 1.2.7에는 `en-US/ko/en-GB`, 나머지는 1.2.8 이후로 미루는 별도 버전 전략이 필요하다.
3. **Play Wave 1 (14~28일):** `en-US`, `ko-KR`. 최소 14일을 보되 각 군에서 300 store visitors 미만이면 28일까지 연장한다.
4. **Play Wave 2 (14~28일):** `es-ES`, `pl-PL`, `uk`, `cs-CZ`. 각 locale conversion과 query 변화를 별도로 본다.
5. **Play Wave 3 (28일):** `de-DE`, `it-IT`, `ro`, `sk`, `bg`, `id`, `ms-MY`, `fil`. iOS Bulgaria/Philippines는 `en-GB` 성과로만 본다.
6. 계절성 완화를 위해 같은 요일 수를 포함하고 앱 버전, 가격, 광고 캠페인, rating prompt, screenshot을 동시에 바꾸지 않는다. 바꿔야 한다면 변경 로그에 confounder로 기록한다.

승자 기준:

- 기본: baseline 대비 store conversion **상대 +10% 이상**, first-time downloads/acquisitions 감소 없음, D1 activation/retention 상대 -5% 이내.
- 노출 확대형 승리: conversion이 ±5% 이내라도 search impressions/visitors가 +15% 이상이고 end-to-end downloads가 +10% 이상이면 유지.
- 표본이 작으면 퍼센트만 보고 확정하지 않고 28일 연장하거나 “판단 보류”로 둔다.

Rollback:

- 7일 연속이며 locale당 누적 100 visitors 이상에서 conversion 상대 -15% 이하, 또는 오해 유입으로 activation -10% 이하이면 해당 locale을 이전 카피로 되돌린다.
- Play는 이전 metadata snapshot을 즉시 재업로드한다. iOS name/subtitle rollback은 새 편집 가능 version/심사가 필요할 수 있으므로 1.2.6 metadata snapshot을 보관하고 App Store Connect 상태에 맞춰 되돌린다. PPO treatment 악화는 즉시 stop하되 stop한 test는 재시작할 수 없다는 점을 기록한다.

## 11. 완료 조건

- [ ] MoneyFit 상표/동명 Finance 앱 위험에 대한 유지 결정이 문서화됨
- [ ] 14개 앱 언어 ↔ iOS 12개 App Store 지원 metadata locale + `en-GB` fallback ↔ Android 14개 locale 매핑이 일치함
- [ ] iOS `ko` 146B, `uk` 110B 문제가 교정되고 모든 keywords가 100B 이하임
- [ ] Android `ms` 중복이 없어지고 `fil`이 추가됨
- [ ] iOS archive와 App Store Connect에서 binary 지원 언어가 실제로 14개로 인식되는지 확인됨
- [ ] 모든 title/name/subtitle/short가 자동 validation과 native QA를 통과함
- [ ] `offline`/local-only 카피는 네트워크 차단 테스트 전까지 노출되지 않음
- [ ] Fastlane preview/precheck/supply validate-only 및 metadata-only upload가 성공함
- [ ] 28일 baseline, Wave별 KPI, rollback snapshot이 저장됨

이 완료 조건을 통과할 때 1.2.7 ASO 작업을 “카피 작성 완료”가 아니라 **검색 노출→제품 페이지→다운로드까지 측정 가능한 출시 완료**로 간주한다.
