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

Match를 통해 인증서 및 프로비저닝 프로파일 동기화

### ios match_new

```sh
[bundle exec] fastlane ios match_new
```

Match를 통해 새로운 인증서 및 프로비저닝 프로파일 생성

### ios generate

```sh
[bundle exec] fastlane ios generate
```

Tuist 프로젝트 생성

### ios install_dependencies

```sh
[bundle exec] fastlane ios install_dependencies
```

Tuist 의존성 설치

### ios clean_tuist

```sh
[bundle exec] fastlane ios clean_tuist
```

Tuist 프로젝트 정리

### ios build_dev

```sh
[bundle exec] fastlane ios build_dev
```

개발 환경 빌드

### ios build_stage

```sh
[bundle exec] fastlane ios build_stage
```

스테이징 환경 빌드

### ios build_prod

```sh
[bundle exec] fastlane ios build_prod
```

프로덕션 환경 빌드

### ios test

```sh
[bundle exec] fastlane ios test
```

모든 테스트 실행

### ios test_scheme

```sh
[bundle exec] fastlane ios test_scheme
```

특정 스킴 테스트 실행

### ios bump_build_number

```sh
[bundle exec] fastlane ios bump_build_number
```

버전 번호 증가 (build number)

### ios set_build_number

```sh
[bundle exec] fastlane ios set_build_number
```

버전 번호 설정

### ios bump_version

```sh
[bundle exec] fastlane ios bump_version
```

버전 문자열 증가 (version string)

### ios archive_dev

```sh
[bundle exec] fastlane ios archive_dev
```

개발 환경 Archive 생성

### ios archive_stage

```sh
[bundle exec] fastlane ios archive_stage
```

스테이징 환경 Archive 생성

### ios archive_prod

```sh
[bundle exec] fastlane ios archive_prod
```

프로덕션 환경 Archive 생성

### ios beta_stage

```sh
[bundle exec] fastlane ios beta_stage
```

스테이징 환경 TestFlight 배포

### ios beta_prod

```sh
[bundle exec] fastlane ios beta_prod
```

프로덕션 환경 TestFlight 배포

### ios beta_external

```sh
[bundle exec] fastlane ios beta_external
```

TestFlight 배포 (외부 테스터에게 배포)

### ios release

```sh
[bundle exec] fastlane ios release
```

App Store에 배포

### ios clean

```sh
[bundle exec] fastlane ios clean
```

프로젝트 정리

### ios check_signing

```sh
[bundle exec] fastlane ios check_signing
```

코드 사이닝 정보 확인

### ios info

```sh
[bundle exec] fastlane ios info
```

프로젝트 정보 출력

### ios ci

```sh
[bundle exec] fastlane ios ci
```

CI 환경에서 실행되는 전체 파이프라인

### ios cd

```sh
[bundle exec] fastlane ios cd
```

CD 환경에서 실행되는 배포 파이프라인

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
