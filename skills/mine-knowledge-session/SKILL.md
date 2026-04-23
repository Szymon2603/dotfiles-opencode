---
name: mine-knowledge-session
description: Protokół sesji budowania wiedzy w knowledge-base. Używa wyłącznie MCP do operacji na plikach. Użyj na początku sesji w projekcie knowledge-base.
---

## Przed sesją

```bash
git pull
```

Jeśli są konflikty — rozwiąż je najpierw zanim zaczniesz.

## Na początku sesji

Pobierz stan bazy przez MCP:

```
knowledge_get_vault_stats()
knowledge_list_directory(path="inbox")
knowledge_list_directory(path="concepts")
knowledge_list_directory(path="connections")
knowledge_list_directory(path="ideas/flight-tracker")
```

Następnie:
1. Powiedz ile plików jest w każdym katalogu
2. Pokaż ostatnie 3 pliki z inbox/ (po nazwie — nie czytaj treści)
3. Zapytaj: "Co chcesz dziś zbadać lub dodać?"

Nie ładuj treści plików na start. Czytaj pełną treść tylko gdy potrzebne.

## Podczas sesji — wszystko przez MCP

Wszystkie operacje na plikach przez narzędzia knowledge_*:

| Operacja | Narzędzie MCP |
|----------|--------------|
| Czytaj plik | `knowledge_read_note` |
| Szukaj | `knowledge_search_notes` |
| Twórz nowy plik | `knowledge_write_note` |
| Edytuj istniejący | `knowledge_patch_note` |
| Zmień frontmatter | `knowledge_update_frontmatter` |
| Zmień tagi | `knowledge_manage_tags` |

Nigdy nie używaj narzędzi write/edit/bash do plików w vault.

## Wikilinki w connections/ (ważne)

W treści plików connections/ zawsze używaj `[[nazwa-konceptu]]`:

```markdown
Ryanair stosuje [[ryanair-rate-limits]] co wymusza
agresywne [[cache-warming]] po stronie klienta.
```

Obsidian buduje graf z wikilinków w treści — nie z frontmatteru.

## Na końcu sesji

1. Wymień nowe/zmodyfikowane pliki tej sesji
2. Uruchom @knowledge-connector na nowych concepts/
3. Uruchom @idea-generator jeśli powstały nowe connections/
4. Commituj i pushuj:

```bash
git add -A
git commit -m "knowledge: [krótki opis]"
git push
```

5. Powiedz: "Spushowano. Zaktualizuj Obsidian."
