---
name: mine-project-workflow
description: Protokół pracy z GitHub Issues — branch, commity, ROADMAP
---

## Protokół przed kodowaniem
1. Przeczytaj treść Issue (poproś użytkownika o wklejenie lub fetch URL)
2. Sprawdź ROADMAP.md — czy feature ma zależności od innych?
3. Stwórz branch: `feature/issue-{N}-{short-kebab-name}`

## Podczas pracy
- Każdy commit referencuje Issue: `feat: dodaj rate limiting (#12)`
- Jeden commit = jedna logiczna zmiana
- Nie mieszaj refactoringu z nową funkcją

## Po zakończeniu
1. Sprawdź wszystkie AC z Issue — każde jako checkbox
2. Uruchom testy jeśli istnieją
3. Zaktualizuj ROADMAP.md — zmień status feature na "done"
4. Zaproponuj treść PR description