---
name: mine-git-conventions
description: Git workflow conventions — branches, commits, PRs, changelog. Use before committing or opening a PR.
---

## Branch naming

Format: `<type>/<issue-N>-<short-kebab-description>`

```
feat/12-ryanair-adapter
fix/18-scheduler-timezone
refactor/20-base-adapter-interface
chore/5-setup-docker-compose
docs/9-update-readme
test/12-ryanair-retry-logic
```

Zasady:
- Type musi pasować do type'u głównego commita na branchu
- Numer Issue zawsze jeśli istnieje — jeśli nie istnieje, stwórz Issue najpierw
- Opis max 4-5 słów, kebab-case, bez czasowników w 3. osobie

---

## Commit messages

Format Conventional Commits:

```
<type>(<scope>): <imperative description> (#N)
```

Przykłady:
```
feat(scraper): add Ryanair adapter with rate limiting (#12)
fix(scheduler): handle APScheduler timezone edge case (#18)
test(scraper): add unit tests for 429 retry logic (#12)
refactor(models): extract BaseAdapter interface (#20)
docs(readme): add local development setup instructions (#9)
chore(docker): add docker-compose for local dev (#5)
```

**Typy:**
- `feat` — nowa funkcjonalność (triggeruje CHANGELOG)
- `fix` — naprawa buga (triggeruje CHANGELOG)
- `refactor` — zmiana kodu bez zmiany zachowania
- `test` — dodanie lub zmiana testów
- `docs` — dokumentacja
- `chore` — konfiguracja, zależności, CI
- `perf` — optymalizacja wydajności

**Zasady atomowości — jeden commit = jedna logiczna zmiana:**
- Nie mieszaj `feat` z `refactor` w jednym commicie
- Nie mieszaj zmian w wielu niezależnych modułach
- Jeśli diff robi dwie niezależne rzeczy → dwa commity
- Pliki konfiguracyjne IDE (`.idea/`, `.vscode/`) nigdy nie trafiają do commita

**Squash:** nigdy nie squashuj — historia jest cenna.
Wyjątek: WIP commity (`wip: ...`) przed otwarciem PR należy zrebase'ować
na atomowe commity przez `git rebase -i`.

---

## Przed każdym commitem

Wykonaj w tej kolejności:

1. `git diff --staged` — przejrzyj co dokładnie committujesz
2. Uruchom testy dla zmienionych modułów:
   - Python: `pytest tests/<module>/ -x`
   - Node/TS: `npm test -- --testPathPattern=<module>`
   - Java/Kotlin: `./gradlew test`
3. Sprawdź czy nie ma przypadkowych plików w staged:
   - `.env`, `*.log`, `__pycache__/`, `.idea/`, `node_modules/`
4. Sprawdź czy nie hardcode'ujesz credentials lub sekretów

Jeśli którykolwiek test nie przechodzi — nie commituj, napraw najpierw.

---

## Pull Request

### Kiedy otwierać PR

- **Solo projekt** (flight-tracker, projekty osobiste): PR opcjonalny —
  możesz commitować bezpośrednio na `main` przy małych zmianach.
  PR warto otworzyć dla większych feature'ów żeby mieć ślad decyzji.
- **Projekt zespołowy**: zawsze PR, review wymagany przed merge.

### Tytuł PR

Taki sam format jak commit message głównej zmiany:
```
feat(scraper): add Ryanair adapter with rate limiting (#12)
```

### Opis PR — szablon

```markdown
## What
[Co zostało zrobione — 1-3 zdania]

## Why
[Dlaczego ta zmiana jest potrzebna — kontekst, problem który rozwiązuje]

## How
[Kluczowe decyzje techniczne, nieoczywiste rozwiązania]
Pomiń jeśli implementacja jest prosta i oczywista.

## Testing
[Jak przetestowano — jakie testy dodano / uruchomiono]

## Checklist
- [ ] Testy przechodzą lokalnie
- [ ] Brak hardcoded credentials
- [ ] CHANGELOG zaktualizowany (jeśli feat/fix)
- [ ] Dokumentacja zaktualizowana (jeśli zmieniono publiczne API)
```

---

## CHANGELOG

Aktualizuj `CHANGELOG.md` przy każdym `feat` i `fix`.

Format (Keep a Changelog):
```markdown
## [Unreleased]

### Added
- Ryanair adapter with rate limiting and exponential backoff (#12)

### Fixed
- APScheduler timezone handling for CET/CEST transitions (#18)
```

Zasady:
- Pisz z perspektywy użytkownika, nie developera
  ("Add price alerts via email" nie "Implement AlertService class")
- Sekcje: `Added` | `Fixed` | `Changed` | `Removed` | `Deprecated`
- Zawsze referencja do Issue na końcu wpisu

---

## Częste błędy — lista kontrolna

Zanim zaproponujesz commit lub PR, sprawdź:

- [ ] Branch name zawiera numer Issue?
- [ ] Commit message w trybie rozkazującym ("add" nie "added")?
- [ ] Jeden commit = jedna logiczna zmiana?
- [ ] Testy uruchomione i przechodzą?
- [ ] Brak plików IDE / debug / secrets w staged?
- [ ] Jeśli `feat` lub `fix` → CHANGELOG zaktualizowany?
- [ ] Jeśli zmieniono publiczne API → docs zaktualizowane?
