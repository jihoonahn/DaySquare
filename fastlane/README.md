fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios match_sync

```sh
[bundle exec] fastlane ios match_sync
```

인증서·프로비저닝 프로파일 동기화 (읽기 전용)

### ios match_new

```sh
[bundle exec] fastlane ios match_new
```

새 인증서·프로비저닝 프로파일 생성

### ios generate

```sh
[bundle exec] fastlane ios generate
```

Tuist 프로젝트 생성

### ios build_prod

```sh
[bundle exec] fastlane ios build_prod
```

프로덕션 IPA 빌드

### ios test

```sh
[bundle exec] fastlane ios test
```

테스트 실행

### ios bump_build_number

```sh
[bundle exec] fastlane ios bump_build_number
```

빌드 번호만 1 증가

### ios archive_prod

```sh
[bundle exec] fastlane ios archive_prod
```

프로덕션 Archive 생성

### ios archive_stage

```sh
[bundle exec] fastlane ios archive_stage
```

스테이징 Archive 생성

### ios beta_stage

```sh
[bundle exec] fastlane ios beta_stage
```

스테이징 TestFlight 배포

### ios beta_prod

```sh
[bundle exec] fastlane ios beta_prod
```

프로덕션 TestFlight 배포

### ios release

```sh
[bundle exec] fastlane ios release
```

App Store 업로드 + 심사 제출

### ios upload_screenshots_only

```sh
[bundle exec] fastlane ios upload_screenshots_only
```

스크린샷만 업로드 (fastlane/screenshots/ JPEG/PNG)

### ios deploy_new_feature

```sh
[bundle exec] fastlane ios deploy_new_feature
```

빌드 번호 증가 후 TestFlight 배포 (stage 또는 prod)

### ios deploy_new_version

```sh
[bundle exec] fastlane ios deploy_new_version
```

버전 문자열 변경 후 빌드 1로 초기화 + TestFlight 배포

### ios clean

```sh
[bundle exec] fastlane ios clean
```

빌드·DerivedData 정리

### ios info

```sh
[bundle exec] fastlane ios info
```

버전·번들 ID 등 정보 출력

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
