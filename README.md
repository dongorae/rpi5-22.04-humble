## 변경 전 파일
- [servo_pkg/src/servo_mgr.cpp](servo_mgr.cpp)

## 변경 전: sysfs GPIO 코드

기존 코드는 `/sys/class/gpio/gpioN`을 직접 열어서 export / direction / value를 설정하는, **레거시 sysfs 방식**을 사용하는 예시입니다. 라즈베리 파이 5 (Ubuntu 24.04) 최신 커널 환경에서는 sysfs GPIO가 기본적으로 비활성화되어, “No such file or directory” 오류를 일으킬 수 있습니다.

---

## 변경 후: libgpiod (Character Device GPIO) 코드

아래 예시는 C++에서 [libgpiod](https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/)를 사용해 GPIO 제어하는 방식으로, sysfs 대신 `/dev/gpiochipX`를 통하는 현대적인 API입니다.

### 1) 준비 사항

1. **호스트 라즈베리 파이 5**(Ubuntu 24.04 등)에서:
   ```bash
   sudo apt-get update
   sudo apt-get install -y gpiod libgpiod-dev
   ```
   - GPIO CLI 도구(`gpiodetect`, `gpioset` 등)와 C++ 개발 헤더 설치

2. **CMakeLists.txt**(또는 빌드 스크립트)에 libgpiod 연결:
   ```cmake
   find_package(PkgConfig REQUIRED)
   pkg_check_modules(LIBGPIOD REQUIRED libgpiodcxx)

   add_executable(servo_mgr servo_mgr.cpp)
   target_include_directories(servo_mgr PRIVATE ${LIBGPIOD_INCLUDE_DIRS})
   target_link_libraries(servo_mgr ${LIBGPIOD_LIBRARIES})
   ```
   - 실제 환경에 맞게 조정

3. **도커 컨테이너 실행** 시에는 `/dev`를 공유하고, `--privileged` 권한을 부여:
   ```bash
   docker run -d --privileged -v /dev:/dev ...
   ```

### 2) `calibrateServo()` 함수 예시

이전에는 `/sys/class/gpio/gpio%d/export`와 `direction`, `value`를 열어서 쓰는 방식이었으나, libgpiod 방식은 다음처럼 간단히 바꿀 수 있습니다:

```cpp
#include <gpiod.hpp>
#include <system_error>
#include <string>

bool ServoMgr::calibrateServo(int pinNum, int pinVal) const {
    // 범위 체크
    if (pinVal < 0 || pinVal > 1 || pinNum < 0) {
        RCLCPP_ERROR(logger_, "Invalid pin: %d, val: %d", pinNum, pinVal);
        return false;
    }

    try {
        // 1) gpiochip0 열기 (실제 RPi5 환경에서 어떤 chip이 맞는지 gpiodetect로 확인 필요)
        gpiod::chip chip("gpiochip0");

        // 2) line 얻기
        gpiod::line line = chip.get_line(pinNum);
        if (!line) {
            RCLCPP_ERROR(logger_, "Failed to get line offset %d", pinNum);
            return false;
        }

        // 3) 출력 방향으로 요청
        line.request({
            /* consumer = */ "deepracer",
            /* direction = */ gpiod::line_request::DIRECTION_OUTPUT,
            /* flags = */ 0
        });

        // 4) 값 설정 (0 or 1)
        line.set_value(pinVal);

        // 5) release (필요시 유지 가능)
        line.release();
    }
    catch (const std::system_error &e) {
        RCLCPP_ERROR(logger_, "GPIO error: %s", e.what());
        return false;
    }
    return true;
}
```

#### 주요 포인트

- **라즈베리 파이 5**에서 원하는 핀에 해당하는 offset을 확인하려면 `gpiodetect`, `gpioinfo` 실행 후 결정
- sysfs(“/sys/class/gpio”) 파일 접근 없이, **libgpiod** API를 통해 요청→제어

### 3) 나머지 코드 수정

- 기존 “`export`/`unexport`/`direction`/`value`” 호출부(열고 쓰기) 제거
- 대신 위 예시처럼 “libgpiod”를 통해 제어하는 로직으로 대체
- ServoMgr의 나머지 로직(servoSubscriber, rawPWMSubscriber)은 그대로 두어도 됨

---

## 결론

- 라즈베리 파이 5 최신 환경에서 **sysfs GPIO**는 비활성화되어 “No such file or directory” 에러가 날 수 있음
- **libgpiod**로 전환하면 커널 설정 수정 없이 최신 방법으로 GPIO 제어 가능
- 컨테이너에서도 “`--privileged -v /dev:/dev`”만 있으면 됨, “`-v /sys:/sys`”는 불필요
``````markdown
