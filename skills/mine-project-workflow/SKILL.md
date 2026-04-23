---
name: mine-project-workflow
description: Protokół pracy z GitHub Issues — branch naming, commity, aktualizacja ROADMAP. Użyj na początku każdej sesji kodowania.
---

## Przed kodowaniem

1. Przeczytaj treść Issue (poproś o numer jeśli nie podano)
2. Sprawdź ROADMAP.md — czy feature ma zależności?
3. Stwórz branch: `feature/issue-{N}-{short-kebab-name}`

## Podczas pracy

- Każdy commit referencuje Issue: `feat: add X (#12)`
- Jeden commit = jedna logiczna zmiana
- Nie mieszaj refactoringu z nową funkcją

## Po zakończeniu

1. Sprawdź wszystkie AC z Issue
2. Uruchom testy dla zmienionych modułów
3. Zaktualizuj ROADMAP.md — zmień status na "done"
4. `@reviewer sprawdź czy Issue #N jest poprawnie zaimplementowany`
