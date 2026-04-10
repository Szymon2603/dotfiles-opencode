# dotfiles-opencode

Globalne skille, agenci i konfiguracja OpenCode.

## Zawartość

```
skills/
  mine-project-workflow/   # protokół pracy z GitHub Issues
  mine-git-conventions/    # conventional commits, branch naming
  mine-knowledge-session/  # pipeline budowania wiedzy
agents/
  reviewer.md              # read-only code review (haiku, subagent)
  knowledge-collector.md   # ekstrakcja faktów inbox→concepts
  knowledge-connector.md   # połączenia concepts→connections
  idea-generator.md        # generowanie pomysłów connections→ideas
AGENTS.md                  # globalne preferencje (PL, stack, styl)
external-skills.txt        # lista zewnętrznych skilli do zainstalowania
install.sh                 # skrypt setup
```

## Instalacja na nowej maszynie

```bash
git clone https://github.com/<ty>/dotfiles-opencode ~/dotfiles-opencode
cd ~/dotfiles-opencode
chmod +x install.sh
./install.sh
```

Skrypt tworzy symlinki z `skills/` i `agents/` do `~/.config/opencode/`
oraz instaluje zewnętrzne skille z `external-skills.txt`.

## Wymagania

- [OpenCode](https://opencode.ai) zainstalowany
- Node.js (dla `npx skills add`)
- Klucz API: Anthropic bezpośrednio lub [OpenCode Zen](https://opencode.ai/zen)

## Dodawanie nowego skilla

```bash
# własny skill
mkdir skills/mine-nowy-skill
cat > skills/mine-nowy-skill/SKILL.md << 'EOF'
---
name: mine-nowy-skill
description: Opis co robi i kiedy używać
---
# Treść skilla...
EOF
./install.sh  # zlinkuje nowy skill

# zewnętrzny skill
echo "nazwa-skilla" >> external-skills.txt
./install.sh
```

## Eksport zainstalowanych skilli

```bash
ls ~/.config/opencode/skills/ > external-skills.txt
```
