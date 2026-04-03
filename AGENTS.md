# Global Agent Rules

Globalny plik instrukcji. Stosuje się do każdej sesji OpenCode.
Reguły projektowe w AGENTS.md w katalogu projektu mają wyższy priorytet.

---

## Język

- Rozmowa, wyjaśnienia, pytania do mnie: **po polsku**
- Kod, komentarze, nazwy zmiennych, commity, PR descriptions: **po angielsku**
- Jeśli zacznę po angielsku — odpowiadaj po angielsku

---

## Styl odpowiedzi

- Krótko i konkretnie. Nie powtarzaj tego co właśnie zrobiłeś długim opisem.
- Jeśli zrobiłeś kilka rzeczy — wypunktuj je jednym zdaniem każda.
- Nie pisz wstępów w stylu "Oczywiście, chętnie pomogę...".
- Jeśli czegoś nie wiesz — powiedz wprost, nie zgaduj.
- Jeśli zadanie jest niejednoznaczne — zadaj jedno precyzyjne pytanie, nie listę.

---

## Autonomia przy zmianach

**Małe zmiany** (rób bez pytania):
- Pojedynczy plik, < ~50 linii diff
- Dodanie jednej funkcji / metody
- Poprawka buga w izolowanym miejscu
- Dodanie testów do istniejącej logiki

**Duże zmiany** (zapytaj najpierw, przedstaw plan):
- Refactoring obejmujący wiele plików
- Zmiana interfejsu / sygnatury publicznej funkcji
- Zmiana schematu bazy danych
- Nowy moduł / serwis / warstwa
- Wszystko co mogłoby złamać istniejące testy

Przy dużych zmianach: opisz co chcesz zrobić i dlaczego, poczekaj na akceptację.

---

## Stack technologiczny

### Backend
- **Python 3.12+** — FastAPI, SQLAlchemy, Pydantic, pytest
- **Node.js / TypeScript** — Express lub Fastify, Zod
- **Java / Kotlin** — Spring Boot, Gradle (edytor: IntelliJ IDEA)

### Frontend
- Angular, React + TypeScript, Vite

### Bazy danych
- PostgreSQL (produkcja), H2 albo SQLite (development / testy)
- Migracje przez Alembic (Python) lub Flyway (Java)

### Infrastruktura
- Docker + docker-compose (lokalne dev)
- Kubernetes przez k3d (lokalne testy k8s)
- WSL2 / Ubuntu na Windows 11 Home

### Narzędzia
- Zarządzanie wersjami: nvm (Node), pyenv (Python), SDKMAN (Java/Kotlin)
- Sekrety: KeePassXC (nie hardcode'uj nigdy żadnych credentials)

---

## Commity

Format Conventional Commits — zawsze:

```
<type>(<scope>): <short description> (#issue)

Types: feat | fix | chore | docs | refactor | test | perf | ci
```

Przykłady:
```
feat(scraper): add Ryanair adapter with rate limiting (#12)
fix(scheduler): handle APScheduler timezone edge case (#18)
test(scraper): add unit tests for 429 retry logic (#12)
refactor(models): extract BaseAdapter interface (#20)
```

Zasady:
- Opis w trybie rozkazującym ("add", nie "added" / "adds")
- Scope = moduł / katalog którego dotyczy
- Zawsze referencja do Issue jeśli istnieje
- Jeden commit = jedna logiczna zmiana, nie mieszaj typów

---

## Testy

- **Zawsze proponuj testy** przy każdej nowej funkcji lub bugfixie
- Dla Pythona: pytest, fixtures zamiast duplikacji setup
- Dla Node/TS: Vitest lub Jest
- Struktura testu: Arrange / Act / Assert (z komentarzem jeśli nieoczywiste)
- Testy jednostkowe dla logiki biznesowej, integracyjne dla I/O
- Mockuj zewnętrzne API — testy nie powinny robić prawdziwych requestów HTTP

---

## Decyzje architektoniczne

Kiedy wybierasz między kilkoma podejściami — wyjaśnij krótko:
- Co wybierasz i dlaczego
- Jakie było główne odrzucone alternatywy i czemu je odrzuciłeś
- Jakie są trade-offy

Przykład dobrego wyjaśnienia:
> "Używam adapter pattern zamiast dziedziczenia — łatwiej mockować w testach
> i dodać nową linię bez zmiany istniejących klas. Alternatywa (subklasy)
> byłaby prostsza na start, ale utrudniłaby testowanie."

Nie wyjaśniaj oczywistych decyzji.

---

## Bezpieczeństwo

Ostrzegaj aktywnie gdy widzisz:
- Credentials / tokeny / klucze API w kodzie lub logach
- SQL budowany przez konkatenację stringów (→ SQL injection)
- Input od użytkownika przekazywany bezpośrednio do shell / eval
- Brak walidacji danych wejściowych na API endpoints
- Zależności z known vulnerabilities (zasugeruj sprawdzenie)
- Secrets w plikach które mogą trafić do repo (.env bez .gitignore)

Format ostrzeżenia: krótko, na początku odpowiedzi, z etykietą `⚠ SECURITY:`.

---

## Czego nie robić

- Nie zmieniaj formattera / lintera bez pytania
- Nie instaluj nowych zależności bez pytania
- Nie usuwaj TODO/FIXME — zamiast tego zapytaj co z nimi zrobić
- Nie commituj zmian w plikach konfiguracyjnych IDE (.idea/, .vscode/)
- Nie dodawaj `print()` / `console.log()` do debugowania — używaj loggera