#!/bin/bash
#
# IOTstack Smoke Test Suite
# ========================
#
# Diese Testsuite fuehrt grundlegende Smoke-Tests fuer das IOTstack-Projekt durch.
# Getestet werden:
# - Syntax aller Bash-Skripte
# - Ausfuehrbarkeit der Skripte
# - Vorhandensein von Shebang-Zeilen
# - Grundlegende Dateistruktur
#
# Ausfuehrung: ./tests/smoke_tests.sh [--verbose|--quiet]
#

set -euo pipefail

# Konfiguration
README_FILE="tests/README.md"
VERBOSE_MODE=false
QUIET_MODE=false

# Farben fuer Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Zaehler
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# temporaere Dateien
SYNTAX_ERRORS_LOG=$(mktemp)
EXECUTABLE_ERRORS_LOG=$(mktemp)
SHEBANG_ERRORS_LOG=$(mktemp)
STRUCTURE_ERRORS_LOG=$(mktemp)

# Cleanup
cleanup() {
    rm -f "$SYNTAX_ERRORS_LOG" "$EXECUTABLE_ERRORS_LOG" "$SHEBANG_ERRORS_LOG" "$STRUCTURE_ERRORS_LOG"
}
trap cleanup EXIT

# Logging-Funktionen
log_info() {
    if [ "$QUIET_MODE" = false ]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

log_success() {
    if [ "$QUIET_MODE" = false ]; then
        echo -e "${GREEN}[PASS]${NC} $1"
    fi
}

log_warning() {
    if [ "$QUIET_MODE" = false ]; then
        echo -e "${YELLOW}[WARN]${NC} $1"
    fi
}

log_error() {
    if [ "$QUIET_MODE" = false ]; then
        echo -e "${RED}[FAIL]${NC} $1"
    fi
}

# Test-Funktionen
increment_test_count() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

record_pass() {
    PASSED_TESTS=$((PASSED_TESTS + 1))
    log_success "$1"
}

record_fail() {
    FAILED_TESTS=$((FAILED_TESTS + 1))
    log_error "$1"
}

record_skip() {
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    log_warning "$1"
}

# Parsing der Command-Line-Argumente
for arg in "$@"; do
    case "$arg" in
        --verbose|-v)
            VERBOSE_MODE=true
            ;;
        --quiet|-q)
            QUIET_MODE=true
            ;;
        --help|-h)
            echo "Verwendung: $0 [OPTIONEN]"
            echo ""
            echo "Optionen:"
            echo "  --verbose, -v  Zeige ausfuehrliche Ausgabe"
            echo "  --quiet, -q    Unterdruecke normale Ausgabe (nur Fehler)"
            echo "  --help, -h     Zeige diese Hilfe"
            echo ""
            echo "Beispiele:"
            echo "  $0                    Fuehre alle Tests aus"
            echo "  $0 --verbose          Fuehre alle Tests mit detaillierter Ausgabe aus"
            echo "  $0 --quiet            Fuehre Tests leise aus"
            exit 0
            ;;
    esac
done

# Header ausgeben
if [ "$QUIET_MODE" = false ]; then
    echo ""
    echo "=========================================="
    echo "  IOTstack Smoke Test Suite"
    echo "=========================================="
    echo ""
fi

# ============================================================================
# TEST 1: Dateistruktur pruefen
# ============================================================================
log_info "Pruefe Dateistruktur..."
increment_test_count

REQUIRED_DIRS=("scripts" ".native" ".templates" "docs")
REQUIRED_FILES=("menu.sh" "scripts/start.sh" "scripts/stop.sh")

STRUCTURE_OK=true

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Fehlendes Verzeichnis: $dir" >> "$STRUCTURE_ERRORS_LOG"
        STRUCTURE_OK=false
    fi
done

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Fehlende Datei: $file" >> "$STRUCTURE_ERRORS_LOG"
        STRUCTURE_OK=false
    fi
done

if [ "$STRUCTURE_OK" = true ]; then
    record_pass "Dateistruktur ist korrekt"
else
    record_fail "Dateistruktur hat Fehler (siehe Details)"
    if [ "$VERBOSE_MODE" = true ] && [ -s "$STRUCTURE_ERRORS_LOG" ]; then
        echo "  Details:"
        cat "$STRUCTURE_ERRORS_LOG" | sed 's/^/    /'
    fi
fi

# ============================================================================
# TEST 2: Syntax aller Bash-Skripte pruefen
# ============================================================================
log_info "Pruefe Syntax aller Bash-Skripte..."

# Alle Bash-Skripte finden (kompatibel mit aelteren Bash-Versionen)
ALL_TESTABLE_SCRIPTS=()
ALL_SCRIPTS_FILE=$(mktemp)

# Finde alle .sh Dateien
find . -type f -name "*.sh" ! -path "./tests/*" ! -path "./.git/*" 2>/dev/null | sort > "$ALL_SCRIPTS_FILE"

# Fuege menu.sh hinzu (falls es existiert und nicht schon in der Liste ist)
if [ -f "menu.sh" ]; then
    echo "./menu.sh" >> "$ALL_SCRIPTS_FILE"
fi

# Lese in Array (ohne Duplikate)
while IFS= read -r line || [ -n "$line" ]; do
    # Nur hinzufuegen wenn nicht leer
    if [ -n "$line" ]; then
        # Pruefe ob bereits im Array (einfache Duplikatspruefung)
        already_added=false
        # Check if array has elements first
        if [ ${#ALL_TESTABLE_SCRIPTS[@]} -gt 0 ]; then
            for existing in "${ALL_TESTABLE_SCRIPTS[@]}"; do
                if [ "$existing" = "$line" ]; then
                    already_added=true
                    break
                fi
            done
        fi
        if [ "$already_added" = false ]; then
            ALL_TESTABLE_SCRIPTS+=("$line")
        fi
    fi
done < "$ALL_SCRIPTS_FILE"

# Cleanup temporaere Datei
rm -f "$ALL_SCRIPTS_FILE"

if [ ${#ALL_TESTABLE_SCRIPTS[@]} -eq 0 ]; then
    record_fail "Keine Bash-Skripte zum Testen gefunden"
else
    log_info "Gefundene Skripte zum Syntax-Check: ${#ALL_TESTABLE_SCRIPTS[@]}"
    
    SYNTAX_OK=true
    SYNTAX_FILES_CHECKED=0
    SYNTAX_FILES_FAILED=0
    
    for script in "${ALL_TESTABLE_SCRIPTS[@]}"; do
        if [ -f "$script" ]; then
            SYNTAX_FILES_CHECKED=$((SYNTAX_FILES_CHECKED + 1))
            if bash -n "$script" 2>>"$SYNTAX_ERRORS_LOG"; then
                if [ "$VERBOSE_MODE" = true ]; then
                    echo "  [OK] Syntax: $script"
                fi
            else
                SYNTAX_OK=false
                SYNTAX_FILES_FAILED=$((SYNTAX_FILES_FAILED + 1))
                echo "Syntaxfehler in: $script" >> "$SYNTAX_ERRORS_LOG"
                log_error "  Syntaxfehler in: $script"
            fi
        fi
    done
    
    increment_test_count
    if [ "$SYNTAX_OK" = true ]; then
        record_pass "Alle ${SYNTAX_FILES_CHECKED} Bash-Skripte haben korrekte Syntax"
    else
        record_fail "${SYNTAX_FILES_FAILED} von ${SYNTAX_FILES_CHECKED} Skripten haben Syntaxfehler"
        if [ "$VERBOSE_MODE" = true ] && [ -s "$SYNTAX_ERRORS_LOG" ]; then
            echo "  Details aus Syntax-Log:"
            cat "$SYNTAX_ERRORS_LOG" | sed 's/^/    /'
        fi
    fi
fi

# ============================================================================
# TEST 3: Shebang-Zeilen pruefen
# ============================================================================
log_info "Pruefe Shebang-Zeilen..."
increment_test_count

SHEBANG_OK=true
SHEBANG_MISSING=0

for script in "${ALL_TESTABLE_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        first_line=$(head -n 1 "$script")
        if [[ ! "$first_line" =~ ^\#!(/bin/bash|/usr/bin/env\ bash) ]]; then
            SHEBANG_OK=false
            SHEBANG_MISSING=$((SHEBANG_MISSING + 1))
            echo "Fehlende/ungueltige Shebang in: $script (erste Zeile: '$first_line')" >> "$SHEBANG_ERRORS_LOG"
        fi
    fi
done

if [ "$SHEBANG_OK" = true ]; then
    record_pass "Alle Bash-Skripte haben korrekte Shebang-Zeilen"
else
    record_fail "${SHEBANG_MISSING} Skripte haben fehlende oder ungültige Shebang-Zeilen"
    if [ "$VERBOSE_MODE" = true ] && [ -s "$SHEBANG_ERRORS_LOG" ]; then
        echo "  Details:"
        cat "$SHEBANG_ERRORS_LOG" | sed 's/^/    /'
    fi
fi

# ============================================================================
# TEST 4: Ausfuehrbarkeit der Skripte pruefen
# ============================================================================
log_info "Pruefe Ausfuehrbarkeit der Skripte..."
increment_test_count

EXECUTABLE_OK=true
NOT_EXECUTABLE=0

# Skripte die ausfuehrbar sein sollten (alle in scripts/, .native/, .templates/)
EXECUTABLE_SCRIPTS=(
    "menu.sh"
    ".native/*.sh"
    ".templates/*/*.sh"
    "scripts/*.sh"
)

for pattern in "${EXECUTABLE_SCRIPTS[@]}"; do
    for script in $pattern; do
        if [ -f "$script" ]; then
            if [ ! -x "$script" ]; then
                EXECUTABLE_OK=false
                NOT_EXECUTABLE=$((NOT_EXECUTABLE + 1))
                echo "Nicht ausfuehrbar: $script" >> "$EXECUTABLE_ERRORS_LOG"
            fi
        fi
    done
done

if [ "$EXECUTABLE_OK" = true ]; then
    record_pass "Alle relevanten Skripte sind ausfuehrbar"
else
    record_fail "${NOT_EXECUTABLE} Skripte sind nicht ausfuehrbar"
    if [ "$VERBOSE_MODE" = true ] && [ -s "$EXECUTABLE_ERRORS_LOG" ]; then
        echo "  Details:"
        cat "$EXECUTABLE_ERRORS_LOG" | sed 's/^/    /'
    fi
fi

# ============================================================================
# TEST 5: Wichtige Template-Skripte pruefen
# ============================================================================
log_info "Pruefe wichtige Template- und Native-Skripte..."

IMPORTANT_SCRIPTS=(
    ".native/rpieasy.sh"
    ".native/rtl_433.sh"
    ".templates/deconz/build.sh"
    ".templates/mariadb/terminal.sh"
    ".templates/influxdb/terminal.sh"
    "scripts/start.sh"
    "scripts/stop.sh"
    "scripts/restart.sh"
    "scripts/update.sh"
    "scripts/docker_backup.sh"
    "scripts/backup_influxdb.sh"
)

IMPORTANT_OK=true
IMPORTANT_MISSING=0
IMPORTANT_FAILED=0

for script in "${IMPORTANT_SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
        IMPORTANT_OK=false
        IMPORTANT_MISSING=$((IMPORTANT_MISSING + 1))
        echo "Fehlend: $script" >> "$STRUCTURE_ERRORS_LOG"
    elif ! bash -n "$script" 2>/dev/null; then
        IMPORTANT_OK=false
        IMPORTANT_FAILED=$((IMPORTANT_FAILED + 1))
        echo "Syntaxfehler: $script" >> "$SYNTAX_ERRORS_LOG"
    fi
done

increment_test_count
if [ "$IMPORTANT_OK" = true ]; then
    record_pass "Alle wichtigen Skripte existieren und haben korrekte Syntax"
else
    record_fail "Probleme mit wichtigen Skripten: ${IMPORTANT_MISSING} fehlend, ${IMPORTANT_FAILED} mit Syntaxfehlern"
    if [ "$VERBOSE_MODE" = true ]; then
        [ -s "$STRUCTURE_ERRORS_LOG" ] && echo "  Fehlende Dateien:" && cat "$STRUCTURE_ERRORS_LOG" | sed 's/^/    /'
        [ -s "$SYNTAX_ERRORS_LOG" ] && echo "  Syntaxfehler:" && cat "$SYNTAX_ERRORS_LOG" | sed 's/^/    /'
    fi
fi

# ============================================================================
# TEST 6: menu.sh - Grundlegende Funktionalitaet
# ============================================================================
log_info "Pruefe menu.sh auf grundlegende Funktionalitaet..."
increment_test_count

MENU_OK=true

# Pruefe ob menu.sh existiert
if [ ! -f "menu.sh" ]; then
    MENU_OK=false
    echo "menu.sh existiert nicht" >> "$STRUCTURE_ERRORS_LOG"
fi

# Pruefe ob menu.sh lesbar ist
if [ -f "menu.sh" ] && [ ! -r "menu.sh" ]; then
    MENU_OK=false
    echo "menu.sh ist nicht lesbar" >> "$EXECUTABLE_ERRORS_LOG"
fi

# Pruefe ob wichtige Funktionen in menu.sh definiert sind
if [ -f "menu.sh" ]; then
    for func in "command_exists" "minimum_version_check" "yml_builder" "docker_setfacl"; do
        if ! grep -q "function $func" menu.sh && ! grep -q "$func()" menu.sh; then
            MENU_OK=false
            echo "Funktion nicht gefunden in menu.sh: $func" >> "$STRUCTURE_ERRORS_LOG"
        fi
    done
    
    # Pruefe ob Docker-Compose-Version definiert ist
    if ! grep -q "COMPOSE_VERSION" menu.sh; then
        MENU_OK=false
        echo "COMPOSE_VERSION nicht definiert in menu.sh" >> "$STRUCTURE_ERRORS_LOG"
    fi
    
    # Pruefe ob Container-Array definiert ist
    if ! grep -q "cont_array" menu.sh; then
        MENU_OK=false
        echo "cont_array nicht definiert in menu.sh" >> "$STRUCTURE_ERRORS_LOG"
    fi
fi

if [ "$MENU_OK" = true ]; then
    record_pass "menu.sh hat alle erwarteten Funktionen und Konfigurationen"
else
    record_fail "menu.sh hat Probleme mit Funktionen oder Konfiguration"
    if [ "$VERBOSE_MODE" = true ] && [ -s "$STRUCTURE_ERRORS_LOG" ]; then
        echo "  Details:"
        grep "menu.sh" "$STRUCTURE_ERRORS_LOG" | sed 's/^/    /' || cat "$STRUCTURE_ERRORS_LOG" | sed 's/^/    /'
    fi
fi

# ============================================================================
# TEST 7: Docker-Skripte pruefen
# ============================================================================
log_info "Pruefe Docker-bezogene Skripte..."
increment_test_count

DOCKER_SCRIPTS=(
    "scripts/start.sh"
    "scripts/stop.sh"
    "scripts/restart.sh"
    "scripts/stop-all.sh"
    "scripts/prune-images.sh"
    "scripts/prune-volumes.sh"
    "scripts/update.sh"
    "scripts/docker_backup.sh"
)

DOCKER_OK=true
DOCKER_SCRIPTS_CHECKED=0
DOCKER_SCRIPTS_FAILED=0

for script in "${DOCKER_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        DOCKER_SCRIPTS_CHECKED=$((DOCKER_SCRIPTS_CHECKED + 1))
        if ! bash -n "$script" 2>/dev/null; then
            DOCKER_OK=false
            DOCKER_SCRIPTS_FAILED=$((DOCKER_SCRIPTS_FAILED + 1))
        fi
    else
        DOCKER_OK=false
        DOCKER_SCRIPTS_FAILED=$((DOCKER_SCRIPTS_FAILED + 1))
    fi
done

if [ "$DOCKER_OK" = true ]; then
    record_pass "Alle ${DOCKER_SCRIPTS_CHECKED} Docker-Skripte sind present und syntaktisch korrekt"
else
    record_fail "${DOCKER_SCRIPTS_FAILED} von ${DOCKER_SCRIPTS_CHECKED} Docker-Skripten haben Probleme"
fi

# ============================================================================
# TEST 8: Native Installationsskripte pruefen
# ============================================================================
log_info "Pruefe Native Installationsskripte..."
increment_test_count

NATIVE_SCRIPTS=(
    ".native/rpieasy.sh"
    ".native/rtl_433.sh"
)

NATIVE_OK=true
NATIVE_CHECKED=0
NATIVE_FAILED=0

for script in "${NATIVE_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        NATIVE_CHECKED=$((NATIVE_CHECKED + 1))
        
        # Pruefe Syntax
        if ! bash -n "$script" 2>/dev/null; then
            NATIVE_OK=false
            NATIVE_FAILED=$((NATIVE_FAILED + 1))
        fi
        
        # Pruefe ob apt-get Befehle vorhanden sind (Indikator fuer Installationsskript)
        if ! grep -q "apt-get" "$script"; then
            NATIVE_OK=false
            NATIVE_FAILED=$((NATIVE_FAILED + 1))
            echo "Keine apt-get Befehle in: $script" >> "$STRUCTURE_ERRORS_LOG"
        fi
        
        # Pruefe ob git clone vorhanden ist (für Paket-Installation)
        if ! grep -q "git clone" "$script" && ! grep -q "git pull" "$script"; then
            # Nicht alle Native-Skripte brauchen git, also nur Warning
            log_warning "  Keine git-Operationen in: $script (kann normal sein)"
        fi
    else
        NATIVE_OK=false
        NATIVE_FAILED=$((NATIVE_FAILED + 1))
    fi
done

if [ "$NATIVE_OK" = true ]; then
    record_pass "Alle ${NATIVE_CHECKED} Native Installationsskripte sind present und syntaktisch korrekt"
else
    record_fail "${NATIVE_FAILED} von ${NATIVE_CHECKED} Native-Skripten haben Probleme"
fi

# ============================================================================
# TEST 9: Template build.sh Skripte pruefen
# ============================================================================
log_info "Pruefe Template build.sh Skripte..."
increment_test_count

TEMPLATE_BUILD_SCRIPTS=(
    ".templates/deconz/build.sh"
    ".templates/nodered/build.sh"
    ".templates/mosquitto/directoryfix.sh"
    ".templates/python/directoryfix.sh"
)

TEMPLATE_OK=true
TEMPLATE_CHECKED=0
TEMPLATE_FAILED=0

for script in "${TEMPLATE_BUILD_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        TEMPLATE_CHECKED=$((TEMPLATE_CHECKED + 1))
        if ! bash -n "$script" 2>/dev/null; then
            TEMPLATE_OK=false
            TEMPLATE_FAILED=$((TEMPLATE_FAILED + 1))
        fi
    else
        # Nicht alle Template-Skripte existieren, das ist okay
        log_warning "  Template-Skript nicht gefunden (kann normal sein): $script"
    fi
done

if [ "$TEMPLATE_OK" = true ]; then
    record_pass "Alle gefundenen Template-Skripte sind syntaktisch korrekt (${TEMPLATE_CHECKED} geprüft)"
else
    record_fail "${TEMPLATE_FAILED} von ${TEMPLATE_CHECKED} Template-Skripten haben Syntaxfehler"
fi

# ============================================================================
# TEST 10: Terminal-Skripte pruefen
# ============================================================================
log_info "Pruefe Terminal-Skripte..."
increment_test_count

TERMINAL_SCRIPTS=(
    ".templates/mariadb/terminal.sh"
    ".templates/influxdb/terminal.sh"
)

TERMINAL_OK=true
TERMINAL_CHECKED=0
TERMINAL_FAILED=0

for script in "${TERMINAL_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        TERMINAL_CHECKED=$((TERMINAL_CHECKED + 1))
        
        # Pruefe Syntax
        if ! bash -n "$script" 2>/dev/null; then
            TERMINAL_OK=false
            TERMINAL_FAILED=$((TERMINAL_FAILED + 1))
        fi
        
        # Pruefe ob docker exec Befehle vorhanden sind (für Terminal-Skripte typisch)
        if ! grep -q "docker exec" "$script" && ! grep -q "docker-compose exec" "$script"; then
            log_warning "  Kein docker exec in: $script (kann normal sein)"
        fi
    else
        TERMINAL_OK=false
        TERMINAL_FAILED=$((TERMINAL_FAILED + 1))
    fi
done

if [ "$TERMINAL_OK" = true ]; then
    record_pass "Alle ${TERMINAL_CHECKED} Terminal-Skripte sind present und syntaktisch korrekt"
else
    record_fail "${TERMINAL_FAILED} von ${TERMINAL_CHECKED} Terminal-Skripten haben Probleme"
fi

# ============================================================================
# ZUSAMMENFASSUNG
# ============================================================================
if [ "$QUIET_MODE" = false ]; then
    echo ""
    echo "=========================================="
    echo "  Test-Zusammenfassung"
    echo "=========================================="
    echo ""
    echo "Gesamt:    $TOTAL_TESTS Tests"
    echo -e "${GREEN}Bestanden: $PASSED_TESTS Tests${NC}"
    echo -e "${RED}Fehlgeschlagen: $FAILED_TESTS Tests${NC}"
    echo -e "${YELLOW}Uebersprungen: $SKIPPED_TESTS Tests${NC}"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}Alle Tests erfolgreich!${NC}"
        echo ""
        echo "Das Projekt scheint in gutem Zustand zu sein."
        exit 0
    else
        echo -e "${RED}Einige Tests sind fehlgeschlagen.${NC}"
        echo ""
        echo "Bitte die Fehlermeldungen oben beachten."
        exit 1
    fi
else
    # Quiet mode - nur Exit-Code
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
fi
