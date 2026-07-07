# oneshot-installer-for-mac

> macOS에서 **Claude Code**를 쓰기 위한 개발 환경을, **터미널 명령 한 줄**로 끝내는 설치기.
> Homebrew · Node.js · Python · Git · Claude Code를 한 번에 준비하고, 설치가 끝나면 **바로 사용**할 수 있게 해 줍니다.

```bash
curl -fsSL https://jikime.github.io/oneshot-installer-for-mac/install.sh | bash
```

---

## 왜 만들었나

macOS에서 Claude Code를 한번 써 보려고 하면, 시작도 하기 전에 준비물부터 만만치 않습니다.

- 패키지 관리자 **Homebrew**를 먼저 설치하고,
- **Node.js**를 깔고, **Python**을 깔고,
- 그다음에야 **Claude Code**를 설치하고…

명령어를 하나하나 찾아 붙여넣고, 설치가 잘 됐는지 확인하고, 터미널에선 `command not found`가 뜨는 **PATH 문제**까지 부딪히게 됩니다. 개발이 익숙한 사람에게도 번거로운데, 이제 막 시작하는 분들에게는 **"본론에 들어가기도 전에 지치는"** 과정이었습니다.

> "그냥 한 번에 설치해 주는 게 있으면 좋겠다."

이 작은 바람에서 출발했습니다. 여러 명령을 순서대로 실행하는 대신, **명령 한 줄이면 필요한 도구가 알아서 깔리고, 끝나면 바로 쓸 수 있도록** 만들었습니다. 준비 과정은 도구에 맡기고, 사용자는 **Claude Code로 만들고 싶은 것에 바로 집중**할 수 있게요.

> Windows 사용자는 [oneshot-installer-for-window](https://github.com/jikime/oneshot-installer-for-window)를 사용하세요.

---

## 무엇을 설치하나

| 도구 | 왜 필요한가 |
| --- | --- |
| **Homebrew** | macOS 패키지 관리자 (없으면 자동으로 설치) |
| **Node.js** | Claude Code 연동 도구 실행에 필요 |
| **Python** (최신 3.x) | 파이썬 기반 작업·스크립트 실행용 |
| **Git** | 버전 관리 (보통 이미 있음 — 없으면 설치) |
| **Claude Code** | 본체 — 터미널에서 쓰는 AI 코딩 도구 |

---

## 사용법

**터미널(Terminal.app 또는 iTerm 등)** 에서 아래 한 줄을 붙여넣습니다. Homebrew 설치 과정에서 **Mac 로그인 비밀번호**를 한 번 물어볼 수 있습니다.

```bash
curl -fsSL https://jikime.github.io/oneshot-installer-for-mac/install.sh | bash
```

설치가 진행되는 동안 **`[1/N]` 단계 표시**가 나오고, 끝나면 각 도구가 어디에 설치됐는지까지 알려줍니다.

### 옵션을 주고 싶다면

```bash
curl -fsSL https://jikime.github.io/oneshot-installer-for-mac/install.sh | bash -s -- --skip-python
```

| 옵션 | 설명 |
| --- | --- |
| (없음) | Homebrew + Node.js + Python + Git + Claude Code 설치 |
| `--skip-python` | Python 제외 |

### 설치 후

설치가 끝나면 스크립트가 **PATH를 현재 창에 바로 반영**하므로, 대개 터미널을 다시 열지 않아도 됩니다. 바로 확인해 보세요.

```bash
node --version
python3 --version
claude --version
git --version
```

혹시 특정 도구가 `not found`로 나오면, 새 터미널 창을 한 번 열면 인식됩니다.

---

## 특징

- **한 줄 설치** — 여러 명령을 순서대로 칠 필요 없이 하나로 끝.
- **진행 단계 표시** — 어디까지 됐는지 단계별로 보여줌.
- **설치 후 바로 사용** — PATH를 현재 세션에 반영(터미널 재시작 대부분 불필요).
- **설치 경로 안내** — 각 도구가 실제로 어디 깔렸는지 표시.
- **멱등** — 이미 있는 도구는 건너뜀. 여러 번 실행해도 안전.

---

## 요구사항

- **macOS** (Apple Silicon / Intel 모두 지원).
- 인터넷 연결. Homebrew 설치 시 관리자(비밀번호) 인증이 한 번 필요할 수 있습니다.
