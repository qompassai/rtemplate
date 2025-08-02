#!/bin/sh
# /qompassai/rust/scripts/quickstart.sh
# Qompass AI Rust Quick Start
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
set -eu
IFS=' 
	'
LOCAL_PREFIX="$HOME/.local"
BIN_DIR="$LOCAL_PREFIX/bin"
CONFIG_DIR="$HOME/.config/rust"
DATA_DIR="$HOME/.local/share"
mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$DATA_DIR"
case ":$PATH:" in
*":$BIN_DIR:"*) ;;
*) PATH="$BIN_DIR:$PATH" ;;
esac
export PATH
NEEDED_TOOLS="git curl tar make clang bash"
MISSING=""
for tool in $NEEDED_TOOLS; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    if [ -x "/usr/bin/$tool" ]; then
      ln -sf "/usr/bin/$tool" "$BIN_DIR/$tool"
      echo " → Added symlink for $tool in $BIN_DIR (not originally in PATH)"
    else
      MISSING="$MISSING $tool"
    fi
  fi
done
if [ -n "$MISSING" ]; then
  echo "⚠ Warning: The following tools are missing (not installed or not symlinkable):$MISSING"
  echo "Please install them manually with your package manager to continue."
  exit 1
fi
cat <<EOF >"/tmp/rust_menu.$USER"
1	Rust Stable (x86_64/Linux)	stable-x86_64-unknown-linux-gnu
2	Rust Nightly (x86_64/Linux)	nightly-x86_64-unknown-linux-gnu
3	Rust Stable (aarch64/Linux)	stable-aarch64-unknown-linux-gnu
4	Rust Stable for Mac (x86_64/macos)	stable-aarch64-apple-darwin
5	Rust Nightly for Mac (aarch64/macos)	nightly-aarch64-apple-darwin
q	Quit
a	All (Advanced)
EOF
printf '╭────────────────────────────────────────────╮\n'
printf '│    Qompass AI · Rust Quick‑Start           │\n'
printf '╰────────────────────────────────────────────╯\n'
printf '    © 2025 Qompass AI. All rights reserved   \n\n'
awk -F '\t' 'NF==3 {printf " %s) %s\n", $1, $2}' "/tmp/rust_menu.$USER"
printf ' a) all   (Advanced)\n'
printf ' q) quit\n\n'
printf "Choose toolchains to install [1]: "
read -r choice
[ -z "$choice" ] && choice="a"
[ "$choice" = "q" ] && exit 0
VERSIONS=""
if [ "$choice" = "a" ]; then
  VERSIONS=$(awk -F '\t' 'NF==3 {print $3}' "/tmp/rust_menu.$USER")
else
  for sel in $choice; do
    SELVER=$(awk -F '\t' -v k="$sel" '$1 == k {print $3}' "/tmp/rust_menu.$USER")
    if [ -z "$SELVER" ]; then
      echo "Unknown option: $sel"
      rm -f "/tmp/rust_menu.$USER"
      exit 1
    fi
    VERSIONS="$VERSIONS $SELVER"
  done
fi
OS="unknown"
case "$(uname -s)" in
Linux*) OS="linux" ;;
Darwin*) OS="macos" ;;
CYGWIN* | MINGW* | MSYS*) OS="windows" ;;
esac
echo "==> Detected OS: $OS"
add_path_to_shell_rc() {
  rcfile=$1
  line="export PATH=\"$BIN_DIR:\$PATH\""
  if [ -f "$rcfile" ]; then
    if ! grep -Fxq "$line" "$rcfile"; then
      printf '\n# Added by Qompass AI Rust quickstart script\n%s\n' "$line" >>"$rcfile"
      echo " → Added PATH export to $rcfile"
    fi
  fi
}
if ! command -v rustup >/dev/null 2>&1; then
  echo "⚠ rustup not found. Installing rustup for $OS ..."
  case "$OS" in
  linux | macos)
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    PATH="$HOME/.cargo/bin:$PATH"
    export PATH
    add_path_to_shell_rc "$HOME/.bashrc"
    add_path_to_shell_rc "$HOME/.zshrc"
    add_path_to_shell_rc "$HOME/.profile"
    ;;
  windows)
    echo "❌ Automated rustup installation is not supported on Windows by this script."
    echo "➡ Please install it manually via https://rustup.rs/"
    rm -f "/tmp/rust_menu.$USER"
    exit 1
    ;;
  *)
    echo "❌ Unknown OS. Cannot install rustup."
    rm -f "/tmp/rust_menu.$USER"
    exit 1
    ;;
  esac
else
  echo "✅ rustup found"
fi
COMPONENTS="cargo clippy rustfmt rust-src rust-docs rustc rust-analyzer llvm-tools-preview"
TARGETS="x86_64-unknown-linux-musl x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu aarch64-apple-darwin wasm32-wasi riscv64gc-unknown-linux-gnu aarch64-unknown-linux-rocm"
CARGO_TOOLS="bacon bacon-ls bat cargo2nix crane cargo-zigbuild cross cargo-debugger cargo-lipo cargo-apk cargo-godot cargo-ndk maturin cargo-leptos cxxbridge-cmd flamegraph cargo-bloat cargo-udeps cargo-sweep nixpkgs-fmt"
echo "==> Installing Rust toolchains..."
for t in $VERSIONS; do
  echo " ▪ Installing $t"
  rustup toolchain install "$t"
  echo "   Adding components to $t"
  for c in $COMPONENTS; do
    rustup component add "$c" --toolchain "$t" 2>/dev/null || true
  done
done
echo "==> Adding cross-compilation targets..."
for t in $VERSIONS; do
  echo " ▪ Processing targets for $t"
  for tgt in $TARGETS; do
    rustup target add "$tgt" --toolchain "$t" 2>/dev/null || true
  done
done
echo "==> Installing popular cargo tools..."
for tool in $CARGO_TOOLS; do
  echo " ▪ Installing $tool"
  cargo install "$tool" --locked --force 2>/dev/null || true
done
if ! command -v zig >/dev/null 2>&1; then
  cargo install zig --locked --force 2>/dev/null || true
fi
echo "✅ Rust cross-compilation environment setup complete!"
echo "→ Please restart your terminal or run 'export PATH=\"$BIN_DIR:\$PATH\"' to update your PATH."
rm -f "/tmp/rust_menu.$USER"
exit 0
