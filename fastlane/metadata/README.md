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

## 메타데이터 없이 빌드만 올리기

메타데이터 업로드를 건너뛰려면 Fastfile의 `release` lane에서:

```ruby
upload_to_app_store(
  skip_metadata: true,  # true면 메타데이터 업로드 안 함
  ...
)
```

현재는 `skip_metadata: false`이므로 이 폴더의 내용이 업로드됩니다.
