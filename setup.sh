#!/usr/bin/env bash
# setup.sh — rejestruje opencode-install jako globalną komendę w ~/.local/bin
# Wołany automatycznie przez bootstrap.sh lub ręcznie.

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
CMD_NAME="opencode-install"
TARGET="$DOTFILES/opencode-install.sh"
LINK="$LOCAL_BIN/$CMD_NAME"

# upewnij się że katalog istnieje
mkdir -p "$LOCAL_BIN"

# utwórz/zaktualizuj symlink
[[ -L "$LINK" ]] && rm "$LINK"
ln -sf "$TARGET" "$LINK"
echo "→ $CMD_NAME linked: $LINK → $TARGET"

# sprawdź czy ~/.local/bin jest w PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$LOCAL_BIN"; then
  echo ""
  echo "⚠ $LOCAL_BIN is not in your PATH."
  echo "  Add one of the following to your shell config (~/.bashrc, ~/.zshrc):"
  echo ""
  echo '    export PATH="$HOME/.local/bin:$PATH"'
  echo ""
  echo "  Then reload: source ~/.bashrc (or ~/.zshrc)"
else
  echo "✓ $LOCAL_BIN is in PATH — '$CMD_NAME' is ready to use"
fi
