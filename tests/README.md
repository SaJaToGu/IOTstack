# IOTstack - Testsuite

Dieses Verzeichnis enthaelt die Testsuite fuer das IOTstack-Projekt.

## Uebersicht

Die Testsuite umfasstd **Smoke-Tests** und **Strukturtests** fuer die wichtigsten Skripte des IOTstack-Projekts. Diese Tests stellen sicher, dass:

- Alle Bash-Skripte syntaktisch korrekt sind
- Wichtige Dateien und Verzeichnisse existieren
- Skripte ausfuehrbar sind
- Skripte korrekte Shebang-Zeilen haben
- Wichtige Funktionen in den Skripten definiert sind

## Testkategorien

Die Testsuite prueft folgende Bereiche:

### 1. Dateistruktur
- Vorhandensein der wichtigsten Verzeichnisse (`.native/`, `.templates/`, `scripts/`, `docs/`)
- Vorhandensein der wichtigsten Dateien (`menu.sh`, `scripts/start.sh`, etc.)

### 2. Syntax-Checks
- Alle Bash-Skripte (`*.sh`) werden auf Syntaxfehler geprüft
- Wichtige Skripte ohne `.sh`-Endung werden ebenfalls geprüft

### 3. Shebang-Pruefung
- Alle Bash-Skripte muessen eine korrekte Shebang-Zeile haben (`#!/bin/bash` oder `#!/usr/bin/env bash`)

### 4. Ausfuehrbarkeit
- Alle Skripte in `scripts/`, `.native/`, `.templates/*/` muessen ausfuehrbar sein

### 5. Wichtige Skripte
- `.native/rpieasy.sh` - Native RPIEasy Installation
- `.native/rtl_433.sh` - Native RTL_433 Installation
- `.templates/deconz/build.sh` - deCONZ Docker-Konfiguration
- `.templates/mariadb/terminal.sh` - MariaDB Terminal-Zugriff
- `.templates/influxdb/terminal.sh` - InfluxDB Terminal-Zugriff
- `scripts/start.sh` - Docker Stack starten
- `scripts/stop.sh` - Docker Stack stoppen
- `scripts/restart.sh` - Docker Stack neustarten
- `scripts/update.sh` - Container updaten
- `scripts/docker_backup.sh` - Docker Backup
- `scripts/backup_influxdb.sh` - InfluxDB Backup

### 6. menu.sh Funktionalitaet
- Vorhandensein wichtiger Funktionen (`command_exists`, `minimum_version_check`, `yml_builder`, `docker_setfacl`)
- Definition der Docker-Compose-Version
- Definition des Container-Arrays

### 7. Docker-Skripte
- Alle Skripte im `scripts/`-Verzeichnis werden geprüft

### 8. Native Installationsskripte
- Syntax-Check für `.native/*.sh`
- Pruefung auf `apt-get` Befehle (Installationsindikator)

### 9. Template build.sh Skripte
- Syntax-Check für alle `build.sh` und `directoryfix.sh` Skripte in Templates

### 10. Terminal-Skripte
- Syntax-Check für alle Terminal-Zugriffs-Skripte
- Pruefung auf `docker exec` Befehle

## Voraussetzungen

- **Bash** (mindestens Version 4, wird normalerweise mit den meisten Linux-Distributionen mitgeliefert)
- **GNU Coreutils** (für grundlegende Dateioperationen)
- **find** (für das Auffinden von Skriptdateien)
- **grep** (für das Durchsuchen von Dateiinhalten)

Alle diese Tools sind standardmaessig auf den meisten Unix-ähnlichen Systemen (Linux, macOS) vorhanden.

## Ausfuehrung

### Alle Tests ausfuehren

```bash
# Wechseln Sie in das Projektverzeichnis
cd ~/IOTstack

# Alle Tests ausfuehren
./tests/smoke_tests.sh
```

### Mit ausfuehrlicher Ausgabe

```bash
./tests/smoke_tests.sh --verbose
# oder
./tests/smoke_tests.sh -v
```

Die ausfuehrliche Ausgabe zeigt detaillierte Informationen zu jedem geprüften Skript.

### Leise Ausfuehrung (nur Exit-Code)

```bash
./tests/smoke_tests.sh --quiet
# oder
./tests/smoke_tests.sh -q
```

Diese Option unterdrueckt alle Ausgaben und gibt nur den Exit-Code zurueck (0 = Erfolg, 1 = Fehler).

### Hilfe anzeigen

```bash
./tests/smoke_tests.sh --help
# oder
./tests/smoke_tests.sh -h
```

## Exit-Codes

| Exit-Code | Bedeutung |
|-----------|-----------|
| 0 | Alle Tests erfolgreich |
| 1 | Ein oder mehrere Tests fehlgeschlagen |

## Testresultate interpretieren

### Erfolgreiche Ausfuehrung

```
==========================================
  IOTstack Smoke Test Suite
==========================================

[INFO] Pruefe Dateistruktur...
[PASS] Dateistruktur ist korrekt
[INFO] Pruefe Syntax aller Bash-Skripte...
[PASS] Alle 15 Bash-Skripte haben korrekte Syntax
[INFO] Pruefe Shebang-Zeilen...
[PASS] Alle Bash-Skripte haben korrekte Shebang-Zeilen
...

==========================================
  Test-Zusammenfassung
==========================================

Gesamt:    10 Tests
Bestanden: 10 Tests
Fehlgeschlagen: 0 Tests
Uebersprungen: 0 Tests

Alle Tests erfolgreich!

Das Projekt scheint in gutem Zustand zu sein.
```

### Fehlgeschlagene Tests

```
[INFO] Pruefe Ausfuehrbarkeit der Skripte...
[FAIL] 3 Skripte sind nicht ausfuehrbar
[INFO] Pruefe Shebang-Zeilen...
[FAIL] 2 Skripte haben fehlende oder ungültige Shebang-Zeilen
...

==========================================
  Test-Zusammenfassung
==========================================

Gesamt:    10 Tests
Bestanden: 7 Tests
Fehlgeschlagen: 3 Tests
Uebersprungen: 0 Tests

Einige Tests sind fehlgeschlagen.

Bitte die Fehlermeldungen oben beachten.
```

Mit der Option `--verbose` erhalten Sie detailliertere Informationen zu den Fehlern.

## Haeufige Probleme und Loesungen

### Problem: Skripte sind nicht ausfuehrbar

**Fehlermeldung:**
```
[FAIL] X Skripte sind nicht ausfuehrbar
```

**Loesung:**
```bash
# Einzelnes Skript
chmod +x pfad/zum/skript.sh

# Alle Skripte im Projekt
find . -name "*.sh" -type f -exec chmod +x {} \;
```

### Problem: Fehlende Shebang-Zeile

**Fehlermeldung:**
```
[FAIL] X Skripte haben fehlende oder ungültige Shebang-Zeilen
```

**Loesung:**
Fuegen Sie die folgende Zeile am Anfang des Skripts ein:
```bash
#!/bin/bash
```

### Problem: Syntaxfehler in Skript

**Fehlermeldung:**
```
[FAIL] Syntaxfehler in: pfad/zum/skript.sh
```

**Loesung:**
Fuehren Sie einen manuellen Syntax-Check durch:
```bash
bash -n pfad/zum/skript.sh
```

Der Fehler wird dann direkt angezeigt. Typische Probleme sind:
- Fehlende schliessende `fi`, `done`, `esac` in Kontrollstrukturen
- Fehlende Semikolons oder Zeilenumbrueche vor `then`, `do`, `else`
- Ungueltige Variablennamen
- Fehlende An fuehrungszeichen

### Problem: Fehlende Dateien oder Verzeichnisse

**Fehlermeldung:**
```
[FAIL] Dateistruktur hat Fehler
```

**Loesung:**
Stellen Sie sicher, dass alle benoetigten Verzeichnisse und Dateien existieren. Sie koennen die fehlenden Elemente mit der `--verbose` Option identifizieren:
```bash
./tests/smoke_tests.sh --verbose
```

## Integration in CI/CD

Die Testsuite kann einfach in CI/CD-Pipelines integriert werden:

### GitHub Actions Beispiel

```yaml
name: IOTstack Tests

on: [push, pull_request]

jobs:
  smoke-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Ausfuehrungsrechte setzen
        run: chmod +x tests/smoke_tests.sh
      - name: Tests ausfuehren
        run: ./tests/smoke_tests.sh --quiet
```

### GitLab CI Beispiel

```yaml
smoke_tests:
  image: alpine:latest
  script:
    - chmod +x tests/smoke_tests.sh
    - ./tests/smoke_tests.sh --quiet
  only:
    - merge_requests
    - main
```

## Entwicklung von Tests

### Neue Tests hinzufuegen

1. Oeffnen Sie die Datei `tests/smoke_tests.sh`
2. Finden Sie den passenden Abschnitt oder erstellen Sie einen neuen Test-Block
3. Folgen Sie dem bestehenden Muster:
   - `log_info` fuer Informationsmeldungen
   - `increment_test_count` um den Test-Zaehler zu erhoehen
   - `record_pass` fuer erfolgreiche Tests
   - `record_fail` fuer fehlgeschlagene Tests
   - `record_skip` fuer uebersprungene Tests

### Test-Beispiel

```bash
log_info "Pruefe neue Funktionalitaet..."
increment_test_count

NEUE_FUNKTION_OK=true

# Pruefungen durchfuehren
if [ ! -f "neue_datei.sh" ]; then
    NEUE_FUNKTION_OK=false
fi

# Binary Check
if grep -q "neue_funktion" menu.sh; then
    : # Alles gut
else
    NEUE_FUNKTION_OK=false
fi

if [ "$NEUE_FUNKTION_OK" = true ]; then
    record_pass "Neue Funktionalitaet ist korrekt implementiert"
else
    record_fail "Neue Funktionalitaet hat Probleme"
fi
```

## Best Practices

1. **Regelmaessig ausfuehren**: Fuehren Sie die Tests nach jeder Aenderung aus
2. **Vor dem Commit**: Fuehren Sie `./tests/smoke_tests.sh` aus, bevor Sie Aenderungen commiten
3. **In Pull Requests**: Integrieren Sie die Tests in Ihre CI-Pipeline, um PRs automatisch zu pruefen
4. **Neue Skripte**: Wenn Sie neue Skripte hinzufuegen, stellen Sie sicher, dass sie:
   - Eine korrekte Shebang-Zeile haben
   - Ausfuehrbar sind (`chmod +x`)
   - Syntaktisch korrekt sind (`bash -n`)

## Dateistruktur der Testsuite

```
tests/
├── smoke_tests.sh    # Haupt-Testskript mit allen Tests
└── README.md         # Diese Dokumentation
```

## Lizenz

Die Testsuite unterliegt der gleichen Lizenz wie das IOTstack-Projekt selbst. Siehe die Haupt-LIZENZ-Datei im Projektroot.

## Beitragen

Bei Fragen oder Problemen mit der Testsuite:
1. Pruefen Sie die häufigen Probleme und Loesungen in dieser README
2. Fuehren Sie die Tests mit `--verbose` aus, um detaillierte Informationen zu erhalten
3. Erstellen Sie ein Issue im Projekt-Repository mit:
   - Der genauen Fehlermeldung
   - Den Schritten zur Reproduktion
   - Ihrer Umgebung (Betriebssystem, Bash-Version)

---

*Dokumentation erstellt fuer das IOTstack-Projekt*
