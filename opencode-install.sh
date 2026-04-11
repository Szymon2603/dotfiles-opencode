#!/usr/bin/env bash
# opencode-install — menedżer skillów i agentów OpenCode
# Użycie:
#   opencode-install                             # czyta .opencode/requirements.txt, instaluje lokalnie
#   opencode-install skill <nazwa> [--global|--local]
#   opencode-install agent <nazwa|./ścieżka> [--global|--local]
#   opencode-install --help
#   opencode-install --list

set -euo pipefail

# ── stałe ──────────────────────────────────────────────────────────────────────
GLOBAL_SKILLS_DIR="$HOME/.config/opencode/skills"
GLOBAL_AGENTS_DIR="$HOME/.config/opencode/agents"
LOCAL_SKILLS_DIR="$(pwd)/.opencode/skills"
LOCAL_AGENTS_DIR="$(pwd)/.opencode/agents"
REQUIREMENTS_FILE="$(pwd)/.opencode/requirements.txt"

# ── kolory ─────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── helpery ────────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}→${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*" >&2; }

usage() {
  cat <<EOF
Usage:
  opencode-install                              Install from .opencode/requirements.txt (local)
  opencode-install skill <name> [--global|-g]   Install a skill
  opencode-install skill <name> [--local|-l]    Install a skill locally
  opencode-install agent <name|./path> [flags]  Install an agent
  opencode-install --list                       List installed skills and agents
  opencode-install --help                       Show this help

Requirements file: .opencode/requirements.txt
  skill:mine-git-conventions   # own skill from dotfiles (symlink)
  skill:playwright             # external skill via npx skills add
  agent:reviewer               # agent from global config
  agent:./agents/my-agent.md   # local agent file
EOF
}

# ── pytanie o zakres ───────────────────────────────────────────────────────────
ask_scope() {
  local default="${1:-local}"
  while true; do
    read -r -p "Install [g]lobal or [l]ocal? (default: $default): " answer
    answer="${answer:-$default}"
    case "$answer" in
      g|global) echo "global"; return ;;
      l|local)  echo "local";  return ;;
      *) warn "Wpisz 'g' lub 'l'" ;;
    esac
  done
}

# ── install skill ──────────────────────────────────────────────────────────────
install_skill() {
  local name="$1"
  local scope="$2"   # global | local | ""

  # ustal scope jeśli nie podano
  if [[ -z "$scope" ]]; then
    scope="$(ask_scope local)"
  fi

  local target_dir
  if [[ "$scope" == "global" ]]; then
    target_dir="$GLOBAL_SKILLS_DIR"
  else
    target_dir="$LOCAL_SKILLS_DIR"
    mkdir -p "$target_dir"
  fi

  # czy to własny skill z dotfiles (istnieje globalnie)?
  if [[ -e "$GLOBAL_SKILLS_DIR/$name" ]]; then
    if [[ "$scope" == "global" ]]; then
      success "skill '$name' already installed globally"
      return
    fi
    # local → symlink z globalnego do lokalnego
    local link="$target_dir/$name"
    [[ -L "$link" ]] && rm "$link"
    ln -sf "$GLOBAL_SKILLS_DIR/$name" "$link"
    success "skill '$name' linked locally (.opencode/skills/$name → global)"
    return
  fi

  # zewnętrzny — npx skills add
  info "Installing external skill '$name' via npx skills add..."
  if [[ "$scope" == "global" ]]; then
    npx --yes skills add "$name" --yes --global
  else
    # npx skills add bez --global instaluje do projektu (CWD)
    npx --yes skills add "$name" --yes
  fi
  success "skill '$name' installed ($scope)"
}

# ── install agent ──────────────────────────────────────────────────────────────
install_agent() {
  local name="$1"
  local scope="$2"   # global | local | ""

  if [[ -z "$scope" ]]; then
    scope="$(ask_scope local)"
  fi

  local target_dir
  if [[ "$scope" == "global" ]]; then
    target_dir="$GLOBAL_AGENTS_DIR"
  else
    target_dir="$LOCAL_AGENTS_DIR"
    mkdir -p "$target_dir"
  fi

  # ścieżka do pliku (zawiera / lub zaczyna się od .)
  if [[ "$name" == *"/"* || "$name" == ./* ]]; then
    local src
    src="$(realpath "$name" 2>/dev/null)" || { error "File not found: $name"; return 1; }
    local basename_name
    basename_name="$(basename "$src")"
    local link="$target_dir/$basename_name"
    [[ -L "$link" ]] && rm "$link"
    ln -sf "$src" "$link"
    success "agent '$basename_name' linked ($scope)"
    return
  fi

  # szukaj w globalnych agentach (z lub bez .md)
  local src=""
  if [[ -f "$GLOBAL_AGENTS_DIR/${name}.md" ]]; then
    src="$GLOBAL_AGENTS_DIR/${name}.md"
  elif [[ -f "$GLOBAL_AGENTS_DIR/${name}" ]]; then
    src="$GLOBAL_AGENTS_DIR/${name}"
  else
    error "Agent '$name' not found in $GLOBAL_AGENTS_DIR"
    return 1
  fi

  if [[ "$scope" == "global" ]]; then
    success "agent '$name' already installed globally"
    return
  fi

  local basename_name
  basename_name="$(basename "$src")"
  local link="$target_dir/$basename_name"
  [[ -L "$link" ]] && rm "$link"
  ln -sf "$src" "$link"
  success "agent '$name' linked locally (.opencode/agents/$basename_name → global)"
}

# ── install z requirements.txt ─────────────────────────────────────────────────
install_from_requirements() {
  local req_file="${1:-$REQUIREMENTS_FILE}"

  if [[ ! -f "$req_file" ]]; then
    error "Requirements file not found: $req_file"
    echo "Create .opencode/requirements.txt with entries like:"
    echo "  skill:mine-git-conventions"
    echo "  agent:reviewer"
    exit 1
  fi

  info "Installing from $req_file (local)..."
  local count=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    # pomiń puste i komentarze
    [[ -z "$line" || "$line" == \#* ]] && continue

    local type name
    type="${line%%:*}"
    name="${line#*:}"
    name="$(echo "$name" | xargs)"  # trim whitespace

    case "$type" in
      skill) install_skill "$name" "local" ;;
      agent) install_agent "$name" "local" ;;
      *)
        warn "Unknown type '$type' in line: $line (expected skill: or agent:)"
        ;;
    esac

    (( count++ )) || true
  done < "$req_file"

  echo ""
  success "Done — $count entries processed from $(basename "$req_file")"
}

# ── list ───────────────────────────────────────────────────────────────────────
list_installed() {
  echo ""
  echo "Global skills ($GLOBAL_SKILLS_DIR):"
  if [[ -d "$GLOBAL_SKILLS_DIR" ]]; then
    ls "$GLOBAL_SKILLS_DIR" | sed 's/^/  /' || echo "  (empty)"
  else
    echo "  (directory not found)"
  fi

  echo ""
  echo "Global agents ($GLOBAL_AGENTS_DIR):"
  if [[ -d "$GLOBAL_AGENTS_DIR" ]]; then
    ls "$GLOBAL_AGENTS_DIR" | sed 's/^/  /' || echo "  (empty)"
  else
    echo "  (directory not found)"
  fi

  echo ""
  echo "Local skills ($LOCAL_SKILLS_DIR):"
  if [[ -d "$LOCAL_SKILLS_DIR" ]]; then
    ls "$LOCAL_SKILLS_DIR" | sed 's/^/  /' || echo "  (empty)"
  else
    echo "  (not found — no .opencode/skills/ in CWD)"
  fi

  echo ""
  echo "Local agents ($LOCAL_AGENTS_DIR):"
  if [[ -d "$LOCAL_AGENTS_DIR" ]]; then
    ls "$LOCAL_AGENTS_DIR" | sed 's/^/  /' || echo "  (empty)"
  else
    echo "  (not found — no .opencode/agents/ in CWD)"
  fi
}

# ── main ───────────────────────────────────────────────────────────────────────
main() {
  if [[ $# -eq 0 ]]; then
    install_from_requirements
    return
  fi

  local cmd="$1"
  shift

  case "$cmd" in
    --help|-h)
      usage
      ;;
    --list|-l)
      list_installed
      ;;
    --file)
      local file="${1:?--file requires a path}"
      install_from_requirements "$file"
      ;;
    skill)
      local name="${1:?skill requires a name}"
      shift
      local scope=""
      for arg in "$@"; do
        case "$arg" in
          --global|-g) scope="global" ;;
          --local|-l)  scope="local"  ;;
        esac
      done
      install_skill "$name" "$scope"
      ;;
    agent)
      local name="${1:?agent requires a name or path}"
      shift
      local scope=""
      for arg in "$@"; do
        case "$arg" in
          --global|-g) scope="global" ;;
          --local|-l)  scope="local"  ;;
        esac
      done
      install_agent "$name" "$scope"
      ;;
    *)
      error "Unknown command: $cmd"
      echo ""
      usage
      exit 1
      ;;
  esac
}

main "$@"
