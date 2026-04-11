# dotfiles-opencode — Agent Rules

Repozytorium globalnej konfiguracji OpenCode dla jednego developera.
Zawiera skille, agentów i globalne preferencje stosowane do każdej sesji.

---

## Kontekst i decyzje projektowe

### Filozofia tego repo

To repo istnieje żeby setup OpenCode był odtwarzalny na każdej maszynie
przez jedno polecenie (`./bootstrap.sh`). Zmiany tu mają efekt globalny —
dotyczą każdej sesji w każdym projekcie.

### Podział: globalne vs per-projekt

Globalne (tu) = dotyczy Ciebie jako developera, niezależnie od projektu:
- Styl komunikacji z agentem
- Format commitów
- Stack technologiczny jako domyślny
- Agenci których używasz wszędzie (reviewer, knowledge pipeline)

Per-projekt (w `.opencode/` danego repo) = specyfika konkretnej aplikacji:
- Schematy danych, wzorce kodu
- Komendy uruchomieniowe
- Konwencje specyficzne dla projektu

### Zasada nazewnictwa skilli

Prefiksy odróżniają źródło skilla:
- `mine-*` — własne skille z tego repo (symlinkowane)
- bez prefiksu w `~/.config/opencode/skills/` — zainstalowane przez `npx skills add`

### Dlaczego nie używamy oh-my-opencode

Świadoma decyzja z czasu projektowania: oh-my-opencode (teraz oh-my-openagent)
to plugin od jednej osoby, budowany w real-time, niestabilny. Natywny system
skills + agents OpenCode jest wystarczający dla projektu solo. Można wrócić
do tej decyzji gdy projekt flight-tracker urośnie do 10+ równoległych zadań.

### Agenci w tym repo

Wszystkie 4 agenty są subagentami (nie primary). Wywołuje się je przez `@nazwa`.

`reviewer` — model haiku (tani), temperature 0.1 (deterministyczny), write: false.
Celowo tani bo code review nie wymaga frontier model — wymaga dokładności.

`knowledge-collector` — model haiku, temperature 0.2. Najważniejsza zasada:
tylko ekstrakcja faktów, zero interpretacji. Niska temperatura = nie wymyśla.

`knowledge-connector` — model sonnet, temperature 0.7. Jedyny agent który może
spekulować (oznacza hipotezy jako "> Hipoteza:"). Sonnet bo połączenia między
konceptami wymagają więcej rozumowania niż prosta ekstrakcja.

`idea-generator` — model sonnet, temperature 1.1. Celowo wysoka temperatura —
ma być zaskakujący. Każdy pomysł musi mieć zakorzenienie w connections/.

---

## Stack technologiczny (domyślny)

- **Backend:** Python 3.12+ (FastAPI, SQLAlchemy, Pydantic, pytest) lub Node.js/TypeScript
- **Frontend:** React + TypeScript, Vite
- **Bazy danych:** PostgreSQL (prod), SQLite (dev/testy)
- **Infrastruktura:** Docker + docker-compose, Kubernetes przez k3d
- **Środowisko:** WSL2 / Ubuntu na Windows 11 Home
- **IDE:** IntelliJ IDEA (Kotlin/Java), VS Code (reszta)
- **Wersje runtime:** nvm (Node), pyenv (Python), SDKMAN (Java/Kotlin)
- **Sekrety:** KeePassXC — nigdy nie hardcode'uj credentials

---

## Preferencje komunikacji

- Odpowiedzi po **polsku**, kod i komentarze po **angielsku**
- Krótko i konkretnie — bez wstępów i podsumowań
- Jeśli czegoś nie wiesz — powiedz wprost
- Jeśli zadanie niejednoznaczne — jedno precyzyjne pytanie

---

## Autonomia przy zmianach

**Małe zmiany** (rób bez pytania): pojedynczy plik, < ~50 linii diff,
dodanie jednej funkcji, poprawka buga w izolowanym miejscu.

**Duże zmiany** (przedstaw plan, poczekaj na akceptację): refactoring
wielu plików, zmiana publicznego interfejsu, nowy moduł, zmiana schematu DB.

---

## Conventional Commits

```
<type>(<scope>): <imperative description> (#issue)
feat | fix | chore | docs | refactor | test | perf | ci
```

- Opis w trybie rozkazującym ("add", nie "added")
- Scope = moduł / katalog
- Referencja do Issue jeśli istnieje
- Jeden commit = jedna logiczna zmiana
- **Nigdy squash** — historia jest cenna
- WIP commity przed PR rebase'uj przez `git rebase -i`

---

## Testy

Zawsze proponuj testy przy nowej funkcji lub bugfixie.
Pytest dla Pythona, fixtures zamiast duplikacji setup.
Testy nie robią prawdziwych requestów HTTP — mockuj zewnętrzne API.

---

## Bezpieczeństwo

Ostrzegaj aktywnie (etykieta `⚠ SECURITY:`) gdy widzisz:
- Credentials / tokeny w kodzie lub logach
- SQL przez konkatenację stringów
- Input od użytkownika do shell / eval
- Brak walidacji na API endpoints
- Sekrety w plikach które mogą trafić do repo

---

## Czego nie robić

- Nie zmieniaj formattera / lintera bez pytania
- Nie instaluj nowych zależności bez pytania
- Nie usuwaj TODO/FIXME — zapytaj co z nimi zrobić
- Nie commituj plików IDE (.idea/, .vscode/)
- Nie używaj print() / console.log() do debugowania — używaj loggera

---

## Jak rozwijać to repo

### Jednorazowy setup nowej maszyny

```bash
./bootstrap.sh
```

Linkuje skille/agentów globalnie, instaluje zewnętrzne skille z `profiles/external-skills.txt`,
rejestruje `opencode-install` jako globalną komendę w `~/.local/bin`.

### Instalacja skilla lub agenta per projekt

Z katalogu projektu:
```bash
opencode-install                         # czyta .opencode/requirements.txt
opencode-install skill playwright        # pyta o zakres
opencode-install skill playwright --local
opencode-install agent reviewer --local
opencode-install agent ./my-agent.md --local
```

### Dodanie nowego własnego skilla

```bash
mkdir skills/mine-nowy-skill
# napisz skills/mine-nowy-skill/SKILL.md z frontmatter name + description
# dodaj wpis do profiles/global.txt:
echo "skill:mine-nowy-skill" >> profiles/global.txt
./bootstrap.sh  # zlinkuje nowy skill globalnie
```

### Dodanie zewnętrznego skilla do globalnego bootstrapu

```bash
# odkomentuj lub dodaj linię w profiles/external-skills.txt
echo "nazwa-skilla" >> profiles/external-skills.txt
./bootstrap.sh
```

### Aktualizacja istniejącego skilla

Edytuj plik bezpośrednio w `skills/<nazwa>/SKILL.md`.
Symlink sprawia że OpenCode widzi zmiany natychmiast — bez reinstalacji.

### Struktura plików

```
bootstrap.sh                  # jednorazowy setup maszyny
opencode-install.sh           # główny CLI — per-projekt i globalne instalacje
setup.sh                      # rejestruje opencode-install w ~/.local/bin
profiles/
  global.txt                  # własne skille/agenci z dotfiles (instalowane globalnie)
  external-skills.txt         # zewnętrzne skille przez npx skills add (globalnie)
skills/                       # własne skille (mine-*)
agents/                       # własni agenci
config/opencode/AGENTS.md     # globalny AGENTS.md
```

### requirements.txt w projekcie

Utwórz `.opencode/requirements.txt` w projekcie:
```
# Własne skille z dotfiles (symlink z globalnego)
skill:mine-git-conventions

# Zewnętrzne
skill:playwright

# Agenci
agent:reviewer
agent:./agents/my-project-agent.md
```

Uruchom `opencode-install` z katalogu projektu żeby zainstalować wszystko lokalnie.
