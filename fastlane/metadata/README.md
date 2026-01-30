# App Store 메타데이터

`fastlane release` 실행 시 이 폴더의 메타데이터가 App Store Connect에 업로드됩니다.

## 폴더 구조

```
metadata/
├── copyright.txt              # 저작권 (예: 2026 Jihoon Ahn)
├── primary_category.txt       # 1차 카테고리 (예: Lifestyle)
├── secondary_category.txt     # 2차 카테고리 (예: Productivity)
├── en-US/                     # 영어 (미국)
│   ├── name.txt               # 앱 이름
│   ├── subtitle.txt           # 부제목 (30자 이하)
│   ├── description.txt        # 앱 설명 (4000자 이하)
│   ├── keywords.txt           # 키워드 (쉼표 구분, 100자 이하)
│   ├── promotional_text.txt  # 프로모션 문구 (170자 이하, 선택)
│   ├── release_notes.txt     # 이번 버전 릴리즈 노트
│   ├── support_url.txt        # 지원 URL
│   ├── marketing_url.txt      # 마케팅 URL (선택)
│   └── privacy_url.txt        # 개인정보 처리방침 URL
├── ko/                     # 한국어 (추가 시 동일 파일들)
└── README.md
```

## 추가 언어

새 언어(예: 한국어)를 넣으려면:

1. `metadata/ko/` 폴더 생성
2. `en-US`와 같은 이름의 `.txt` 파일들 복사 후 내용만 한국어로 수정

## 카테고리 값

- **primary_category / secondary_category**:  
  [App Store Connect 카테고리 목록](https://developer.apple.com/app-store/categories/) 참고  
  예: Lifestyle, Productivity, Utilities, Health, Music 등

## 주의

- **support_url**, **marketing_url**, **privacy_url**은 실제 URL로 바꿔야 합니다.
- **description**, **keywords**는 앱에 맞게 수정하세요.
- **release_notes.txt**는 버전마다 수정하면 해당 버전의 "새 기능"으로 올라갑니다.

## precheck "unreachable URLs" 오류

`fastlane release` 전 precheck에서 **No broken urls → unreachable URLs (예: example.com 404)** 가 나오면,  
precheck가 검사하는 건 **App Store Connect에 저장된 URL**입니다. 로컬 `privacy_url.txt`는 이미 올바른 URL이어도, ASC에 예전 값(example.com)이 있으면 404로 나옵니다.

**해결:**

1. **App Store Connect에서 직접 수정 (첫 버전 권장)**  
   App Store Connect → 내 앱 → DaySquare → 앱 정보 → 개인정보 처리방침 URL을 `https://ahnjihoon.notion.site/DaySquare-...` (또는 사용 중인 URL)로 수정 후 저장.  
   첫 버전에서는 `fastlane upload_metadata_only` 가 "No data" 오류로 실패하는 경우가 있어, 이 방법이 가장 확실합니다.
2. **로컬 메타데이터로 ASC 덮어쓰기 (이미 버전이 있는 경우)**  
   `fastlane upload_metadata_only` 를 실행하면, 이 폴더의 메타데이터(privacy/support/marketing URL 포함)만 App Store Connect에 올라갑니다. (IPA 업로드 없음) 첫 버전이 아닐 때 시도해 보세요.
3. **Notion이 계속 unreachable일 때**  
   GitHub Pages 등 Apple 서버가 접근 가능한 호스팅에 개인정보/지원 페이지를 두고, `privacy_url.txt` 등을 그 주소로 바꾼 뒤 1번 또는 2번 실행.

## 메타데이터 없이 빌드만 올리기

메타데이터 업로드를 건너뛰려면 Fastfile의 `release` lane에서:

```ruby
upload_to_app_store(
  skip_metadata: true,  # true면 메타데이터 업로드 안 함
  ...
)
```

현재는 `skip_metadata: false`이므로 이 폴더의 내용이 업로드됩니다.
