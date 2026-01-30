# DaySquare 배포 가이드

이 문서는 DaySquare 앱의 배포 프로세스와 Release 노트 자동화, Discord 알림 기능 사용법을 설명합니다.

## 📋 목차

1. [Release 노트 자동화](#release-노트-자동화)
2. [Discord 알림 설정](#discord-알림-설정)
3. [배포 워크플로우](#배포-워크플로우)

---

## 📝 Release 노트 자동화

### 릴리즈 노트 작성

새로운 기능이나 변경사항이 있을 때 릴리즈 노트를 작성합니다:

```bash
# 방법 1: Fastlane 명령어로 직접 작성
fastlane write_changelog changelog:"새로운 알람 기능 추가
- 반복 알람 기능 개선
- UI 버그 수정
- 성능 최적화"

# 방법 2: CHANGELOG.txt 파일 직접 편집
# fastlane/CHANGELOG.txt 파일을 열어서 내용 수정
```

### 릴리즈 노트 파일 위치

- **파일 경로**: `fastlane/CHANGELOG.txt`
- 이 파일의 내용이 TestFlight 업로드 시 자동으로 사용됩니다.

### 릴리즈 노트 자동 사용

배포 시 `changelog` 옵션을 생략하면 `CHANGELOG.txt` 파일이 자동으로 읽혀집니다:

```bash
# CHANGELOG.txt 파일 내용이 자동으로 사용됨
fastlane beta_stage

# 또는 직접 지정
fastlane beta_stage changelog:"직접 작성한 변경사항"
```

---

## 🔔 Discord 알림 설정

### 1. Discord Webhook 생성

1. Discord 서버에서 **서버 설정** → **연동** → **웹후크** 이동
2. **새 웹후크** 클릭
3. 웹후크 이름 설정 (예: "DaySquare 배포 알림")
4. 채널 선택 (배포 알림을 받을 채널)
5. **웹후크 URL 복사**

### 2. 환경 변수 설정

`fastlane/.env.default` 파일에 Discord Webhook URL 추가:

```bash
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"
```

### 3. Discord 알림 동작

다음 상황에서 Discord 알림이 자동으로 전송됩니다:

- ✅ **배포 성공**: TestFlight 업로드 성공 시
- ❌ **배포 실패**: 빌드/업로드 실패 시
- 📱 **정보 포함**: Version, Build Number, Environment

### 4. Discord 알림 예시

**성공 알림:**

```
✅ TestFlight 배포 성공 (Staging)
DaySquare 앱이 TestFlight에 성공적으로 업로드되었습니다.

Version: 1.0    Build: 2    Environment: Staging
```

**실패 알림:**

```
❌ TestFlight 배포 실패 (Staging)
배포 중 오류가 발생했습니다: [에러 메시지]
```

---

## 🔐 Match: DaySquare용 프로파일이 없을 때

앱 이름을 **WithDay → DaySquare**로 바꾼 뒤, Match 저장소에는 아직 **WithDay**용 프로파일만 있고 **DaySquare**용이 없으면 아래 오류가 납니다.

```
No matching provisioning profiles found for 'AppStore_me.jihoon.DaySquare.mobileprovision'
Provisioning profiles in your repo: ... WithDay.mobileprovision ...
```

**한 번만** DaySquare용 인증서·프로비저닝 프로파일을 생성해 Match 저장소에 넣어야 합니다.

### 1. 사전 확인

- [Apple Developer](https://developer.apple.com/account)에서 **App ID**가 등록되어 있어야 합니다.
  - `com.jihoon.DaySquare`
  - `com.jihoon.DaySquare.Widget`
- Match 저장소(`Matchfile`의 `git_url`)에 **쓰기 권한**이 있어야 합니다.

### 2. DaySquare용 프로파일 생성

프로젝트 루트에서 실행:

```bash
fastlane match_new
```

- Apple ID 로그인 및 앱 전용 비밀번호 입력이 뜨면 입력합니다.
- **Distribution Certificate**와 **Provisioning Profile**이 새로 만들어지고, Match 저장소(Git)에 push됩니다.
- 이후에는 `match_sync`(readonly)만 사용하면 됩니다.

### 3. 다시 배포

```bash
fastlane beta_stage   # 또는 beta_prod
```

---

## 🚀 배포 워크플로우

### 시나리오 1: 새 기능 추가 (빌드 번호만 증가)

같은 버전에서 새로운 기능을 추가하거나 버그를 수정한 경우:

```bash
# 1. 릴리즈 노트 작성
fastlane write_changelog changelog:"새로운 기능 추가
- 알람 반복 설정 개선
- UI 버그 수정"

# 2. 빌드 번호 자동 증가 + 배포
fastlane deploy_new_feature environment:stage
# 또는
fastlane deploy_new_feature environment:prod
```

**동작:**

- 빌드 번호 자동 증가 (예: 1 → 2)
- 버전 문자열 유지 (예: 1.0)
- TestFlight 업로드
- Discord 알림 전송

### 시나리오 2: 새 버전 배포 (버전 문자열 변경)

메이저/마이너 버전 업데이트:

```bash
# 1. 릴리즈 노트 작성
fastlane write_changelog changelog:"버전 1.1 업데이트
- 새로운 위젯 기능 추가
- 알람 스케줄링 개선
- 전체적인 UI 개선"

# 2. 새 버전 배포
fastlane deploy_new_version version:"1.1" environment:stage
# 또는
fastlane deploy_new_version version:"1.1" environment:prod
```

**동작:**

- 버전 문자열 변경 (예: 1.0 → 1.1)
- 빌드 번호 초기화 (1로 설정)
- TestFlight 업로드
- Discord 알림 전송

### 시나리오 3: 수동 배포

개별 단계를 수동으로 실행:

```bash
# 1. 릴리즈 노트 작성 (선택사항)
fastlane write_changelog changelog:"변경사항..."

# 2. 빌드 번호 증가 (선택사항)
fastlane bump_build_number

# 3. 배포
fastlane beta_stage    # Staging 환경
fastlane beta_prod     # Production 환경
fastlane beta_external # 외부 테스터 배포
```

---

## 📚 주요 명령어 요약

### 릴리즈 노트 관리

```bash
# 릴리즈 노트 작성
fastlane write_changelog changelog:"변경사항 내용"
```

### 버전 관리

```bash
# 빌드 번호 증가
fastlane bump_build_number

# 빌드 번호 설정
fastlane set_build_number build_number:5

# 버전 문자열 변경
fastlane bump_version version:"1.1"
```

### 배포

```bash
# 새 기능 배포 (빌드 번호 자동 증가)
fastlane deploy_new_feature environment:stage

# 새 버전 배포 (버전 문자열 변경)
fastlane deploy_new_version version:"1.1" environment:stage

# 수동 배포
fastlane beta_stage
fastlane beta_prod
fastlane beta_external
```

### 정보 확인

```bash
# 현재 버전 정보 확인
fastlane info
```

---

## 💡 팁

1. **릴리즈 노트는 항상 작성하세요**
   - TestFlight에서 테스터들이 변경사항을 확인할 수 있습니다.
   - `CHANGELOG.txt` 파일을 미리 작성해두면 자동으로 사용됩니다.

2. **Discord 알림은 선택사항입니다**
   - `DISCORD_WEBHOOK_URL`이 설정되어 있지 않으면 알림이 전송되지 않습니다.
   - 에러 없이 무시됩니다.

3. **환경별 배포**
   - `environment:stage`: 스테이징 환경 (테스트용)
   - `environment:prod`: 프로덕션 환경 (실제 배포용)

4. **빌드 번호는 자동 관리**
   - `deploy_new_feature` 사용 시 빌드 번호가 자동으로 증가합니다.
   - 수동으로 관리할 필요가 없습니다.

---

## 🔧 문제 해결

### 릴리즈 노트가 적용되지 않을 때

- `fastlane/CHANGELOG.txt` 파일이 존재하는지 확인
- 파일 내용이 비어있지 않은지 확인
- `fastlane write_changelog` 명령어로 다시 작성

### Discord 알림이 오지 않을 때

- `fastlane/.env.default`에 `DISCORD_WEBHOOK_URL`이 올바르게 설정되었는지 확인
- Discord 웹후크 URL이 유효한지 확인
- 웹후크가 삭제되지 않았는지 확인

### 버전 정보가 잘못되었을 때

- `fastlane info` 명령어로 현재 버전 확인
- `fastlane bump_version` 또는 `fastlane set_build_number`로 수정
