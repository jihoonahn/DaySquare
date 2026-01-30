# 버전 1.0 되돌리기 가이드

TestFlight는 **1.0 (빌드만 올리기)** 로 유지하고, **정식 출시할 때 1.0** 을 쓰기 위한 되돌리기 방법입니다.

---

## 1. 이미 적용된 변경 (지금 상태)

다음 파일들을 **1.0 / 빌드 2** 로 맞춰 두었습니다.

| 파일 | 변경 내용 |
|------|-----------|
| `Projects/App/iOS/Support/Info.plist` | `CFBundleShortVersionString` 1.1 → **1.0**, `CFBundleVersion` 1 → **2** |
| `Projects/App/Widget/Support/Info.plist` | `CFBundleShortVersionString` 1.1 → **1.0**, `CFBundleVersion` 1 → **2** |
| `Configuration/Shared.xcconfig` | `CURRENT_PROJECT_VERSION` 1 → **2** |

- **버전**: 1.0  
- **빌드**: 2 (1.0 (1) 이 이미 TestFlight에 있다고 가정)

---

## 2. 수동으로 되돌릴 때 (다른 버전/빌드로 바꿀 때)

### 2-1. 버전 문자열 (Version)

**iOS 앱**

- `Projects/App/iOS/Support/Info.plist`
- `CFBundleShortVersionString` → 원하는 값 (예: `1.0`)

**위젯**

- `Projects/App/Widget/Support/Info.plist`
- `CFBundleShortVersionString` → **앱과 동일한 값**

### 2-2. 빌드 번호 (Build)

**앱·위젯 공통**

- `Projects/App/iOS/Support/Info.plist` → `CFBundleVersion`
- `Projects/App/Widget/Support/Info.plist` → `CFBundleVersion`
- `Configuration/Shared.xcconfig` → `CURRENT_PROJECT_VERSION`

세 곳을 **같은 숫자**로 맞추기 (예: `2`, `3`, …).

### 2-3. Tuist 사용 시

`tuist generate` 를 다시 하면, xcconfig·Info.plist 값이 빌드에 반영됩니다.

```bash
tuist generate
```

---

## 3. Fastlane으로 배포할 때

### TestFlight: 버전 유지, 빌드만 올리기

```bash
fastlane deploy_new_feature environment:stage
```

- 버전 문자열 그대로 (예: 1.0)
- 빌드 번호만 자동 증가

### 정식 출시 시 1.0 으로 올리기

이미 1.0 (2), 1.0 (3) … 으로 테스트했다면, 그중 하나를 골라 **같은 1.0 (N)** 으로 스토어에 제출하면 됩니다.  
버전을 새로 올리지 않아도 됩니다.

---

## 4. 체크리스트

- [ ] `Info.plist` (iOS, Widget) 버전/빌드 수정
- [ ] `Configuration/Shared.xcconfig` 의 `CURRENT_PROJECT_VERSION` 수정
- [ ] `tuist generate` 실행
- [ ] `fastlane info` 로 버전/빌드 확인
- [ ] `fastlane beta_stage` 로 TestFlight 배포

---

## 5. 현재 설정 확인

```bash
fastlane info
```

**Version: 1.0**, **Build: 2** 로 나오면 되돌리기가 적용된 상태입니다.

이후 TestFlight는 `deploy_new_feature` 로 빌드만 올려서 **1.0 (3), 1.0 (4), …** 로 계속 가면 됩니다.
