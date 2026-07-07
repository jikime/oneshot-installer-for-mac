#!/usr/bin/env bash
#
# One-shot macOS dev-tools installer — for using Claude Code.
# Installs Homebrew (if missing) → Node.js, Python (latest 3.x), Git → Claude Code,
# then makes them usable in the current shell.
#
# Usage:
#   curl -fsSL https://jikime.github.io/oneshot-installer-for-mac/install.sh | bash
#
# Options (pass after `bash -s --`):
#   curl -fsSL .../install.sh | bash -s -- --skip-python
#   --skip-python   Skip Python
#
set -euo pipefail

# ── output helpers ───────────────────────────────────────────────────
if [ -t 1 ]; then
  CYAN=$'\033[0;36m'; GREEN=$'\033[1;32m'; YELLOW=$'\033[0;33m'; RED=$'\033[0;31m'; DIM=$'\033[2m'; NC=$'\033[0m'
else
  CYAN=''; GREEN=''; YELLOW=''; RED=''; DIM=''; NC=''
fi
info() { printf '  %s%s%s\n' "$CYAN" "$1" "$NC"; }
ok()   { printf '  %s%s%s\n' "$GREEN" "$1" "$NC"; }
warn() { printf '  %s%s%s\n' "$YELLOW" "$1" "$NC"; }
err()  { printf '  %sERROR: %s%s\n' "$RED" "$1" "$NC" >&2; }
dim()  { printf '  %s%s%s\n' "$DIM" "$1" "$NC"; }

SKIP_PYTHON=false
while [ $# -gt 0 ]; do
  case "$1" in
    --skip-python) SKIP_PYTHON=true; shift ;;
    --help|-h)
      echo "Usage: curl -fsSL <url>/install.sh | bash [-s -- --skip-python]"; exit 0 ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

banner() {
  echo ""
  echo "  ╔════════════════════════════════════════╗"
  echo "  ║  Dev Tools Installer (macOS)            ║"
  echo "  ║  Node.js · Python · Git · Claude Code   ║"
  echo "  ╚════════════════════════════════════════╝"
  echo ""
}

# ── Homebrew ─────────────────────────────────────────────────────────
ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    ok "Homebrew already installed."
  else
    info "Installing Homebrew (it may ask for your Mac password)..."
    # Homebrew's installer prompts for sudo via /dev/tty, so it works even when
    # this script itself is piped from curl. It also installs the Xcode Command
    # Line Tools (which include git).
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Load brew into THIS shell (Apple Silicon: /opt/homebrew, Intel: /usr/local).
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  command -v brew >/dev/null 2>&1
}

# brew_install <formula> <name> <step> <total>
brew_install() {
  local pkg="$1" name="$2" step="$3" total="$4"
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    ok "[$step/$total] $name is already installed."
    return
  fi
  info "[$step/$total] Installing $name (brew install $pkg) — this may take a few minutes..."
  if brew install "$pkg"; then
    ok "[$step/$total] $name installed."
  else
    warn "[$step/$total] $name install failed — you may need to install it manually."
  fi
}

# install_claude <step> <total>
install_claude() {
  local step="$1" total="$2"
  if command -v claude >/dev/null 2>&1; then
    ok "[$step/$total] Claude Code is already installed."
    return
  fi
  info "[$step/$total] Installing Claude Code — this may take a minute..."
  # Official native installer; falls back to npm (node is installed) if needed.
  curl -fsSL https://claude.ai/install.sh | bash || warn "native Claude Code installer reported an error."
  export PATH="$HOME/.local/bin:$PATH"
  if ! command -v claude >/dev/null 2>&1; then
    warn "Falling back to: npm install -g @anthropic-ai/claude-code"
    npm install -g @anthropic-ai/claude-code || warn "Claude Code install failed — install it manually."
  fi
  ok "[$step/$total] Claude Code step done."
}

# show_tool <cmd> <label>
show_tool() {
  local p
  if p="$(command -v "$1" 2>/dev/null)"; then
    printf '  %s%-8s %s%s\n' "$GREEN" "$2" "$p" "$NC"
  else
    printf '  %s%-8s not found yet — open a new terminal to use it.%s\n' "$DIM" "$2" "$NC"
  fi
}

# ── main ─────────────────────────────────────────────────────────────
banner

if ! ensure_brew; then
  err "Homebrew is not available — cannot continue."
  dim "Install Homebrew from https://brew.sh and re-run this script."
  exit 1
fi

# Count steps for the [i/N] progress labels.
TOTAL=3               # node + git + claude
$SKIP_PYTHON || TOTAL=$((TOTAL + 1))

STEP=0
STEP=$((STEP + 1)); brew_install node   "Node.js"            "$STEP" "$TOTAL"
if ! $SKIP_PYTHON; then STEP=$((STEP + 1)); brew_install python "Python (latest 3.x)" "$STEP" "$TOTAL"; fi
# git usually ships with the Xcode CLT that Homebrew installs — count it either way.
STEP=$((STEP + 1))
if command -v git >/dev/null 2>&1; then
  ok "[$STEP/$TOTAL] Git is already installed ($(command -v git))."
else
  brew_install git "Git" "$STEP" "$TOTAL"
fi
STEP=$((STEP + 1)); install_claude "$STEP" "$TOTAL"

echo ""
ok "Installation complete!"
echo ""
dim "Installed:"
show_tool node   "node"
$SKIP_PYTHON || show_tool python3 "python"
show_tool git    "git"
show_tool claude "claude"
echo ""
dim "Try it now:  node --version ; claude --version"
dim "(If anything shows \"not found yet\", open a new terminal.)"
echo ""
