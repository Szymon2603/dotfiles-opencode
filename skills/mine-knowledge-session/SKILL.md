---
name: mine-knowledge-session
description: Sesja pracy z personal knowledge base — skanowanie concepts/connections/inbox, obsługa podkatalogów, pipeline log, archiwizacja. Używaj na początku każdej sesji z knowledge repo.
---

# Skill: mine-knowledge-session

## Struktura katalogów

```
concepts/
  <temat>/
    <podtemat>.md
  archived/
    <temat>/
connections/
  <typ>/
  archived/
inbox/
  archived/
.pipeline/
  run.log
```

Zasady:
- Max 3 poziomy głębokości (root / temat / podtemat)
- `archived/` jest zawsze pomijane w automatycznym skanowaniu
- `.pipeline/run.log` — commitowalny, append-only, jeden wiersz = jeden run agenta

## Na początku sesji

1. Skanuj rekurencyjnie `concepts/**/*.md`, `connections/**/*.md`, `inbox/*.md` — pomijaj `archived/`
2. Podsumuj grupując po podkatalogach:
   - "concepts/programming: 5 plików, concepts/architecture: 2 pliki"
   - Jeśli katalog nie ma podkatalogów — podaj liczbę plików w root
3. Sprawdź `.pipeline/run.log` i wykryj anomalie pipeline'u:
   - Plik w `inbox/` bez wpisu `knowledge-collector` → `⚠ Brakujący krok: collector dla inbox/X.md`
   - Plik w `concepts/` bez wpisu `knowledge-connector` → `⚠ Brakujący krok: connector dla concepts/X.md`
   - Plik w `connections/` bez wpisu `idea-generator` → `⚠ Brakujący krok: idea-generator dla connections/X.md`
   - Jeśli log nie istnieje — poinformuj użytkownika i kontynuuj
4. Zapytaj: "Co chcesz dziś zbadać lub dodać?"

## Podczas sesji

**Tworzenie nowych plików:**
- Nowe fakty → proponuj ścieżkę z podkatalogiem, np. `concepts/programming/python.md`
  - Jeśli podkatalog pasujący do tematu już istnieje → używaj go
  - Jeśli nie → zaproponuj nowy podkatalog lub root, zapytaj użytkownika o decyzję
- Nowe połączenia → `connections/<typ-połączenia>/nazwa.md`
- Nowe luźne notatki → `inbox/nazwa.md`
- Zapisuj WSZYSTKO — sortowanie jest na później

**Archiwizacja (trigger w języku naturalnym):**
- Gdy użytkownik mówi np. "archiwizuj concepts/programming/python.md" lub "archiwizuj concepts/programming/" → patrz sekcja Archiwizacja poniżej

**Idempotentność agentów:**
- Przed uruchomieniem `@knowledge-connector` lub `@idea-generator` → sprawdź log
- Jeśli wpis dla danego pliku istnieje → zapytaj:
  `"knowledge-connector był już uruchomiony dla concepts/python.md (2026-04-10 14:35). Uruchomić ponownie? [t/n]"`

## Pipeline log

Lokalizacja: `.pipeline/run.log` w katalogu głównym knowledge repo.

Format wiersza:
```
<ISO8601> | <agent> | <źródło> [→ <cel>] | <status>
```

Przykłady:
```
2026-04-10T14:32:00 | knowledge-collector | inbox/note.md → concepts/programming/python.md | SUCCESS
2026-04-10T14:35:00 | knowledge-connector | concepts/programming/python.md | SUCCESS
2026-04-10T15:00:00 | idea-generator | connections/tech-to-business/automation.md | SUCCESS
2026-04-10T15:10:00 | archive | concepts/old.md → concepts/archived/old.md | SUCCESS
```

Zasady:
- Każdy run agenta = nowy wiersz (nie nadpisuj istniejących wpisów)
- Status: `SUCCESS` lub `SKIPPED` (jeśli użytkownik odmówił ponownego uruchomienia)
- Jeśli `.pipeline/` nie istnieje — utwórz katalog i plik przy pierwszym uruchomieniu
- Log jest commitowalny razem z plikami knowledge

## Archiwizacja

**Trigger:** użytkownik mówi np.:
- `"archiwizuj concepts/programming/python.md"` — archiwizacja pojedynczego pliku
- `"archiwizuj concepts/programming/"` — archiwizacja całego podkatalogu

**Kroki agenta:**
1. Przesuń plik/katalog zachowując strukturę podkatalogów:
   - `concepts/programming/python.md` → `concepts/archived/programming/python.md`
   - `connections/tech/api.md` → `connections/archived/tech/api.md`
2. Utwórz katalogi docelowe jeśli nie istnieją
3. Dopisz do logu wiersz z agentem `archive`:
   ```
   2026-04-10T15:10:00 | archive | concepts/programming/python.md → concepts/archived/programming/python.md | SUCCESS
   ```
4. Potwierdź akcję użytkownikowi listą przeniesionych plików

**Ręczny podgląd archiwum:**
- `"pokaż archiwum concepts/programming"` → agent listuje pliki w `concepts/archived/programming/`
- `"pokaż całe archiwum"` → listuje wszystkie pliki ze wszystkich `archived/`

**Archiwum NIE jest skanowane automatycznie** przy starcie sesji. Dostęp tylko na żądanie.

## Traceability — śledzenie pochodzenia

Każdy plik (poza `inbox/`) musi zawierać sekcję `## Sources` na końcu z linkami do plików źródłowych.

**Konwencja sekcji `## Sources`:**

Plik `concepts/<temat>/<podtemat>.md` — powstał z inbox:
```markdown
## Sources
- [inbox/my-note.md](../../../inbox/my-note.md)
- [inbox/another-note.md](../../../inbox/another-note.md)
```

Plik `connections/<typ>/<nazwa>.md` — powstał z concepts i/lub inbox:
```markdown
## Sources
- [concepts/programming/python.md](../../../concepts/programming/python.md)
- [concepts/architecture/event-driven.md](../../../concepts/architecture/event-driven.md)
- [inbox/raw-idea.md](../../../inbox/raw-idea.md)
```

Plik `ideas/<nazwa>.md` — powstał z connections i/lub concepts:
```markdown
## Sources
- [connections/tech-to-business/automation.md](../../../connections/tech-to-business/automation.md)
- [concepts/programming/python.md](../../../concepts/programming/python.md)
```

**Zasady:**
- Linki są relatywne do lokalizacji pliku
- Agent wypełnia `## Sources` automatycznie przy tworzeniu pliku na podstawie tego skąd pochodzi treść
- Przy archiwizacji pliku — zaktualizuj linki w plikach które go cytują (lub zostaw z adnotacją `[ARCHIVED]`)
- Sekcja `## Sources` jest zawsze ostatnią sekcją pliku

## Na końcu sesji

1. Wylistuj wszystkie nowe i zmienione pliki (z pełnymi ścieżkami podkatalogów)
2. Sprawdź log — dla każdego nowego pliku wymień brakujące etapy pipeline'u (jeśli jakieś są)
3. Uruchom `@knowledge-connector` na nowych plikach z `concepts/`
   - Jeśli connector był już uruchamiany dla danego pliku → zapytaj o potwierdzenie przed ponownym uruchomieniem
4. Uruchom `@idea-generator` jeśli powstały nowe pliki w `connections/`
   - Jeśli idea-generator był już uruchamiany → j.w.
5. Podsumuj w 3 zdaniach co nowego wiemy w tej sesji
