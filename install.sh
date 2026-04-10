#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
OPENCODE_DIR="$HOME/.config/opencode"

# Utwórz katalogi jeśli nie istnieją
mkdir -p "$OPENCODE_DIR/skills"
mkdir -p "$OPENCODE_DIR/agents"

# ── własne skille (symlinki z dotfiles) ──
echo "→ Linkowanie własnych skilli..."
for skill_dir in "$DOTFILES/skills"/*/; do
  name="$(basename "$skill_dir")"
  target="$OPENCODE_DIR/skills/$name"
  # usuń stary symlink jeśli istnieje, nie dotykaj katalogów
  [ -L "$target" ] && rm "$target"
  ln -sf "$skill_dir" "$target"
  echo "  ✓ $name"
done

# ── własni agenci (symlinki z dotfiles) ──
echo "→ Linkowanie agentów..."
for agent_file in "$DOTFILES/agents"/*.md; do
  name="$(basename "$agent_file")"
  target="$OPENCODE_DIR/agents/$name"
  [ -L "$target" ] && rm "$target"
  ln -sf "$agent_file" "$target"
  echo "  ✓ $name"
done

# ── globalny AGENTS.md ──
if [ -f "$DOTFILES/config/opencode/AGENTS.md" ]; then
  ln -sf "$DOTFILES/config/opencode/AGENTS.md" "$OPENCODE_DIR/AGENTS.md"
  echo "→ AGENTS.md zlinkowany"
fi

# ── zewnętrzne skille z listy ──
EXT_FILE="$DOTFILES/external-skills.txt"
if [ -f "$EXT_FILE" ]; then
  echo "→ Instalacja zewnętrznych skilli..."
  while IFS= read -r skill || [ -n "$skill" ]; do
    # pomiń puste linie i komentarze
    [[ -z "$skill" || "$skill" == #* ]] && continue
    echo "  installing: $skill"
    npx --yes skills add "$skill" || echo "  ⚠ błąd przy $skill, kontynuuję"
  done < "$EXT_FILE"
fi

echo ""
echo "✅ Setup gotowy. Uruchom opencode i sprawdź skill tool."
