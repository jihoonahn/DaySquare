<div align="center">
    <img src="assets/header.svg"></br>
    <img src="https://img.shields.io/badge/Swift-6.0-f05318.svg" />
    <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" />
    <img src="https://img.shields.io/badge/Tuist-4.0+-blue.svg" />
</div>

# WithDay

**WithDay**는 알람과 스케줄을 효율적으로 관리할 수 있는 iOS 애플리케이션입니다.

## 🚀 주요 기능

- **알람 관리**: AlarmKit을 활용한 정확한 알람 스케줄링
- **스케줄 관리**: 일정 및 메모 관리
- **OAuth 인증**: Apple Sign In 및 Google Sign In 지원
- **클라우드 동기화**: Supabase를 통한 데이터 동기화
- **오프라인 지원**: SwiftData를 활용한 로컬 데이터 저장
- **위젯 지원**: 홈 화면 위젯 제공
- **다국어 지원**: 다국어 인터페이스

## 📋 요구사항

- macOS 13.0+
- Xcode 15.0+
- Swift 6.0+
- Tuist 4.0+
- iOS 17.0+ (타겟 디바이스)

## 🛠 설치 및 실행

### 1. 저장소 클론

```bash
git clone https://github.com/jihoonahn/withDay.git
cd withDay
```

### 2. Tuist 설치

```bash
curl -Ls https://install.tuist.io | bash
```

### 3. 의존성 설치

```bash
tuist install
```

### 4. 프로젝트 생성

```bash
tuist generate
```

### 5. 환경 변수 설정

Xcode Scheme에서 환경 변수를 설정하거나 `.xcconfig` 파일에 추가:

```
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 6. Xcode에서 실행

생성된 `WithDay.xcworkspace` 파일을 열고 실행합니다.

## 🏗 프로젝트 구조

```
withDay/
├── Projects/
│   ├── App/                    # 메인 애플리케이션
│   │   ├── iOS/                # iOS 앱 소스
│   │   └── Widget/             # 위젯 익스텐션
│   ├── Feature/                # Feature 레이어
│   │   ├── HomeFeature/         # 홈 화면
│   │   ├── AlarmsFeature/      # 알람 관리
│   │   ├── SchedulesFeature/   # 스케줄 관리
│   │   ├── SettingsFeature/    # 설정
│   │   ├── LoginFeature/        # 로그인
│   │   ├── SplashFeature/      # 스플래시
│   │   ├── MainFeature/        # 메인 탭
│   │   └── RootFeature/        # 루트 네비게이션
│   ├── Domain/                 # Domain 레이어
│   │   ├── AlarmsDomain/       # 알람 도메인
│   │   ├── SchedulesDomain/    # 스케줄 도메인
│   │   ├── UsersDomain/        # 사용자 도메인
│   │   └── ...
│   ├── Core/                   # Core 레이어
│   │   ├── SupabaseCore/       # Supabase 클라이언트
│   │   ├── SwiftDataCore/      # SwiftData 로컬 저장소
│   │   ├── AuthCore/           # 인증 (Apple, Google OAuth)
│   │   ├── NotificationCore/   # 알림 관리
│   │   └── AlarmSchedulesCore/ # 알람 스케줄링
│   └── Shared/                 # Shared 레이어
│       ├── Dependency/         # DI 컨테이너
│       ├── Designsystem/       # 디자인 시스템
│       ├── Localization/       # 다국어 지원
│       └── Utility/            # 유틸리티
├── Tuist/                      # Tuist 설정
│   ├── ProjectDescriptionHelpers/
│   └── Templates/
└── Configuration/              # 환경별 설정 파일
    ├── App/
    ├── Core/
    ├── Domain/
    └── Feature/
```

## 🏛 아키텍처

WithDay는 **Clean Architecture**와 **Modular Architecture**를 기반으로 구성되어 있습니다.

### 레이어 구조

- **Feature Layer**: SwiftUI Views, Reducers (Rex 프레임워크)
- **Domain Layer**: 비즈니스 로직, Entities, UseCases
- **Core Layer**: 외부 서비스 연동 (Supabase, SwiftData, OAuth)
- **Shared Layer**: 공통 유틸리티 및 디자인 시스템

### 상태 관리

[Rex](https://github.com/pelagornis/swift-rex) 프레임워크를 사용하여 Redux 패턴 기반의 상태 관리를 구현합니다.

### 의존성 주입

`DIContainer`를 통해 모든 의존성을 관리하며, 테스트 가능한 구조를 유지합니다.

자세한 내용은 [DEPENDENCY_GUIDE.md](./DEPENDENCY_GUIDE.md)를 참고하세요.

## 🔧 기술 스택

### 프레임워크 및 라이브러리

- **Tuist**: 프로젝트 생성 및 관리
- **Rex**: 상태 관리 (Redux 패턴)
- **Supabase**: 백엔드 및 인증
- **SwiftData**: 로컬 데이터 저장
- **AlarmKit**: 알람 스케줄링
- **RefineUI Icons**: 아이콘 시스템

### 주요 의존성

```swift
- swift-rex: Redux 패턴 상태 관리
- supabase-swift: Supabase 클라이언트
- refineui-system-icons: 시스템 아이콘
- swift-log: 로깅
```

## 📱 주요 기능 상세

### 알람 관리
- AlarmKit을 활용한 정확한 알람 스케줄링
- 반복 알람 지원
- 알람 활성화/비활성화

### 스케줄 관리
- 일정 생성 및 수정
- 메모 기능
- 캘린더 뷰

### 인증
- Apple Sign In
- Google Sign In (Supabase OAuth)
- 사용자 프로필 관리

### 데이터 동기화
- Supabase를 통한 클라우드 동기화
- SwiftData를 활용한 오프라인 지원
- 자동 동기화

## 🧪 테스트

```bash
# 모든 테스트 실행
tuist test

# 특정 타겟 테스트
xcodebuild test -workspace WithDay.xcworkspace -scheme WithDay-dev
```

## 🚀 빌드 및 배포

### 개발 환경

```bash
tuist generate
# Xcode에서 WithDay-dev 스킴 선택 후 실행
```

### 스테이징 환경

```bash
# Xcode에서 WithDay-stage 스킴 선택 후 실행
```

### 프로덕션 환경

```bash
# Xcode에서 WithDay-prod 스킴 선택 후 Archive
```

### Fastlane

```bash
# Fastlane을 통한 배포 (설정 필요)
fastlane ios beta
```

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다. 자세한 내용은 [LICENSE](./LICENSE) 파일을 참고하세요.

## 🤝 기여

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📚 참고 문서

- [의존성 주입 가이드](./DEPENDENCY_GUIDE.md)
- [Tuist 문서](https://docs.tuist.io)
- [Supabase 문서](https://supabase.com/docs)
- [Rex 문서](https://github.com/pelagornis/swift-rex)
