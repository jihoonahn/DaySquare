# App Store 스크린샷 가이드

스크린샷은 **App Store 제출 시 필수**입니다. 아래 두 가지 중 하나를 선택하면 됩니다.

---

## 방법 1: App Store Connect에서 수동 업로드 (권장)

가장 단순한 방법입니다.

1. [App Store Connect](https://appstoreconnect.apple.com) → **내 앱** → **DaySquare**
2. **앱 스토어** 탭 → 해당 버전 선택
3. **스크린샷** 섹션에서 **+** 클릭
4. 기기별로 이미지 업로드

### 필수 크기 (2024 기준)

| 기기 | 해상도 | 비고 |
|------|--------|------|
| **iPhone 6.7"** | 1290 x 2796 px | iPhone 14 Pro Max 등 (필수) |
| **iPhone 6.5"** | 1284 x 2778 px | iPhone 11 Pro Max, 14 Plus 등 |
| **iPhone 5.5"** | 1242 x 2208 px | iPhone 8 Plus (선택, 일부 지역) |
| **iPad Pro 12.9"** | 2048 x 2732 px | iPad 앱인 경우 |

- **최소 3장**, 보통 **6~10장** 권장
- **iPhone 6.7"** 또는 **6.5"** 한 세트는 반드시 필요

### 이 방법 쓸 때 Fastlane 설정

`fastlane release` 시 스크린샷 업로드를 건너뛰려면 Fastfile에서:

```ruby
upload_to_app_store(
  skip_screenshots: true,  # 스크린샷은 Connect에서 수동 업로드
  ...
)
```

이미 `skip_screenshots: true`로 되어 있으면, 스크린샷은 **반드시 App Store Connect에서만** 올리면 됩니다.

---

## 방법 2: Fastlane으로 스크린샷 업로드

스크린샷 파일을 프로젝트에 두고 `fastlane release` 시 함께 올리려면:

### 1. 폴더 구조

```
fastlane/screenshots/
├── en-US/
│   ├── iPhone-6.7-1.png    # 1290 x 2796
│   ├── iPhone-6.7-2.png
│   ├── iPhone-6.7-3.png
│   └── ...
└── ko/                          # 한국어 (Fastlane은 "ko"만 인식, ko-KR 아님)
    ├── iPhone-6.7-1.png
    └── ...
```

- **파일명**: `[기기]-[순서].png` (예: `iPhone-6.7-1.png`, `iPhone-6.5-1.png`)
- **기기 이름**: `iPhone-6.7`, `iPhone-6.5`, `iPhone-5.5`, `iPad-Pro-12.9` 등

### 2. 이미지 준비

- 시뮬레이터 또는 실제 기기에서 캡처
- Photoshop, Figma 등으로 위 해상도에 맞게 리사이즈
- **PNG** 또는 **JPEG** 사용

### 3. Fastfile 설정

스크린샷을 Fastlane으로 올리려면:

```ruby
upload_to_app_store(
  skip_screenshots: false,
  ...
)
```

그리고 `fastlane release` 실행 시 `fastlane/screenshots/` 안의 이미지가 업로드됩니다.

---

## 정리

| 방법 | 장점 | 단점 |
|------|------|------|
| **Connect 수동** | 설정 없음, 바로 업로드 | 매번 웹에서 올려야 함 |
| **Fastlane 폴더** | 한 번 넣어두면 `release` 시 자동 업로드 | 폴더 구조·해상도 맞춰야 함 |

- **첫 출시**나 **스크린샷 자동화가 필요 없으면** → **방법 1 (Connect 수동)** 추천
- **여러 버전/언어를 자동으로 올리고 싶으면** → **방법 2 (Fastlane)** 사용

어느 쪽이든 **스크린샷 이미지는 반드시 준비**해야 합니다.
