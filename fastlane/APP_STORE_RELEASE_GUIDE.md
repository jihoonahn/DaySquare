# App Store 정식 배포 가이드

TestFlight에서 테스트가 완료된 후, App Store에 정식 배포하는 방법입니다.

---

## 📋 배포 전 체크리스트

### 필수 확인 사항

- [ ] **TestFlight에서 충분히 테스트 완료**
- [ ] **앱 정보 완성** (App Store Connect에서)
  - 앱 설명, 키워드, 카테고리
  - 스크린샷 (필수)
  - 앱 아이콘
  - 개인정보 처리방침 URL (필요한 경우)
- [ ] **버전 정보 확인**
  - 현재 버전: `1.0`
  - 빌드 번호: TestFlight에 올린 것과 동일하거나 더 높은 번호
- [ ] **법적 정보**
  - Export Compliance (암호화 사용 여부) - 이미 `ITSAppUsesNonExemptEncryption: false` 설정됨
  - 연령 등급
  - 라이선스 정보

---

## 🚀 배포 방법

### 방법 1: Fastlane으로 자동 업로드 (권장)

#### 1단계: 빌드 업로드

```bash
fastlane release
```

이 명령어는:
- 프로덕션 환경으로 Archive 생성
- App Store Connect에 빌드 업로드
- **자동 심사 제출은 하지 않음** (`submit_for_review: false`)

#### 2단계: App Store Connect에서 심사 제출

1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. **내 앱** → **DaySquare** 선택
3. **앱 스토어** 탭 → **버전 또는 플랫폼** 섹션
4. **+ 버전 또는 플랫폼** 클릭 (또는 기존 버전 선택)
5. **빌드 선택** → 업로드된 빌드 선택
6. **앱 정보 입력**
   - 새 기능 (What's New)
   - 스크린샷 (이미 있으면 확인)
   - 앱 설명, 키워드 등
7. **심사 제출** 버튼 클릭

---

### 방법 2: Xcode Organizer로 수동 업로드

1. Xcode → **Window** → **Organizer**
2. **Archives** 탭
3. 최신 Archive 선택 → **Distribute App**
4. **App Store Connect** 선택
5. **Upload** 선택
6. **Automatically manage signing** 또는 **Manual** 선택
7. **Upload** 클릭

---

## 📝 배포 워크플로우 예시

### 시나리오: 1.0 버전 정식 출시

```bash
# 1. 현재 버전 확인
fastlane info
# → Version: 1.0, Build: 2 (또는 3)

# 2. App Store에 빌드 업로드
fastlane release

# 3. App Store Connect에서:
#    - 빌드 선택
#    - 앱 정보 입력
#    - 심사 제출
```

---

## ⚙️ Fastlane `release` Lane 설정

현재 설정:
- `submit_for_review: false` - 자동 심사 제출 안 함
- `automatic_release: false` - 자동 출시 안 함
- `skip_metadata: false` - 메타데이터 업로드
- `skip_screenshots: false` - 스크린샷 업로드

### 자동 심사 제출하려면

`fastlane/Fastfile`의 `release` lane에서:

```ruby
upload_to_app_store(
  skip_metadata: false,
  skip_screenshots: false,
  force: true,
  submit_for_review: true,  # ← true로 변경
  automatic_release: false
)
```

⚠️ **주의**: `submit_for_review: true`로 설정하면 자동으로 심사가 제출됩니다. 모든 정보가 완성되었는지 확인 후 사용하세요.

---

## 🔍 업로드 후 확인

### 1. App Store Connect에서 빌드 확인

1. App Store Connect → **내 앱** → **DaySquare**
2. **TestFlight** 탭 → **iOS 빌드**
3. 업로드된 빌드가 **"처리 중"** → **"처리 완료"** 상태로 변경되는지 확인
4. **앱 스토어** 탭에서 해당 빌드를 선택할 수 있는지 확인

### 2. 빌드 처리 시간

- 일반적으로 **10-30분** 소요
- 처리 완료되면 **앱 스토어** 탭에서 빌드 선택 가능

---

## 📱 심사 제출 후

### 심사 상태 확인

- **심사 대기 중**: 제출 완료, Apple 심사 대기
- **심사 중**: Apple이 앱 검토 중
- **거부됨**: 문제 발견 → 수정 후 재제출
- **승인됨**: 출시 준비 완료

### 자동 출시 vs 수동 출시

- **자동 출시** (`automatic_release: true`): 승인되면 자동으로 출시
- **수동 출시** (`automatic_release: false`): 승인 후 수동으로 "출시" 버튼 클릭

---

## 🛠️ 문제 해결

### 빌드 업로드 실패

```bash
# 1. 인증서/프로파일 확인
fastlane match_sync

# 2. 프로젝트 정리 후 재시도
fastlane clean
fastlane release
```

### 빌드가 App Store Connect에 안 보임

- 빌드 처리 대기 중일 수 있음 (10-30분)
- **TestFlight** 탭에서 먼저 확인
- 처리 완료 후 **앱 스토어** 탭에서 선택 가능

### 심사 거부 시

1. App Store Connect에서 거부 사유 확인
2. 문제 수정
3. 새 빌드 업로드 (`fastlane release`)
4. 재제출

---

## 💡 팁

1. **첫 출시 전**: App Store Connect에서 모든 필수 정보 입력 완료
2. **스크린샷**: 최소 6.5인치 iPhone용 스크린샷 필수
3. **개인정보 처리방침**: 사용자 데이터 수집 시 필수
4. **심사 시간**: 보통 24-48시간 (첫 출시는 더 오래 걸릴 수 있음)
5. **버전 관리**: TestFlight와 동일한 빌드 번호 사용 가능 (또는 더 높은 번호)

---

## 📚 관련 문서

- [App Store Connect 가이드](https://developer.apple.com/app-store-connect/)
- [Fastlane App Store 배포 문서](https://docs.fastlane.tools/actions/upload_to_app_store/)
