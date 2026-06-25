#!/bin/bash
# pushEasyLang.sh — Robust push fuer myLangSite -> easy-lang.git
# Erstellt: 2026-05-24 (Session 18)
#
# Sicherheits-Features:
#   - Verifiziert Repo-Root (verhindert versehentliches Pushen des Home-Verzeichnisses)
#   - Verifiziert Remote-URL
#   - Bricht bei Commit-Fehler ab (kein blinder Push danach)
#   - Force-Push nur mit expliziter Bestaetigung (oder --yes Flag)
#   - Try normal push first, fallback auf force
#
# Benutzung:
#   ./pushEasyLang.sh                 # Interaktiv: fragt bei Force-Push nach
#   ./pushEasyLang.sh --yes           # Auto-Confirm fuer Force-Push (CI-tauglich)
#   ./pushEasyLang.sh -m "Mein Text"  # Custom Commit-Message

set -e  # Bei jedem Fehler abbrechen

# === Trap: bei JEDEM Exit (Erfolg oder Fehler) auf ENTER warten ===
trap 'echo ""; read -p "Drücke ENTER zum Schliessen..." _' EXIT

# === Konfiguration ===
EXPECTED_REPO="C:\Users\pc\Desktop\HTML Snippets\New Project"
EXPECTED_REMOTE="https://github.com/einsundnull/newProjectGuidelines.git"
BRANCH="main"

# === Args parsen ===
AUTO_YES=0
COMMIT_MSG="Update vom $(date '+%Y-%m-%d %H:%M:%S')"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes|-y) AUTO_YES=1; shift ;;
    -m)       COMMIT_MSG="$2"; shift 2 ;;
    *) echo "Unbekanntes Argument: $1"; exit 1 ;;
  esac
done

# === 1. In Projektverzeichnis wechseln ===
cd "$EXPECTED_REPO" || {
  echo "FEHLER: Pfad existiert nicht: $EXPECTED_REPO"
  exit 1
}

# === 2. Repo-Root verifizieren (CRITICAL: nicht Home-Repo!) ===
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [ -z "$REPO_ROOT" ]; then
  echo "FEHLER: Kein Git-Repository in $EXPECTED_REPO"
  echo "  Loesung: 'git init' in diesem Verzeichnis ausfuehren."
  exit 1
fi

# Pfad-Vergleich. Git Bash kennt zwei Schreibweisen fuer Windows-Pfade:
#   /c/Users/pc/...   (MSYS-Stil, von cd akzeptiert)
#   C:/Users/pc/...   (Windows-Stil, oft von git zurueckgegeben)
# Normalisiere beide zu C:/... in lowercase fuer den Vergleich.
normalize_path() {
  local p="$1"
  p="$(echo "$p" | tr '\\' '/')"
  # /c/foo -> C:/foo
  if [[ "$p" =~ ^/([a-zA-Z])/(.*)$ ]]; then
    p="$(echo "${BASH_REMATCH[1]}" | tr 'a-z' 'A-Z'):/${BASH_REMATCH[2]}"
  fi
  # c:/foo -> C:/foo (lowercase Laufwerksbuchstabe -> uppercase)
  if [[ "$p" =~ ^([a-z]):(.*)$ ]]; then
    p="$(echo "${BASH_REMATCH[1]}" | tr 'a-z' 'A-Z'):${BASH_REMATCH[2]}"
  fi
  echo "$p"
}

REPO_NORM="$(normalize_path "$REPO_ROOT")"
EXPECTED_NORM="$(normalize_path "$EXPECTED_REPO")"

if [ "$REPO_NORM" != "$EXPECTED_NORM" ]; then
  echo "FEHLER: Falsches Git-Repo aktiv!"
  echo "  Erwartet: $EXPECTED_NORM"
  echo "  Aktiv:    $REPO_NORM"
  echo "  Wahrscheinlich existiert ein .git im Eltern-Verzeichnis (z.B. C:/Users/pc/.git)."
  echo "  Loesung: 'git init' in $EXPECTED_REPO ausfuehren, damit dieses Verzeichnis sein eigenes Repo bekommt."
  exit 1
fi

# === 3. Remote verifizieren ===
ACTUAL_REMOTE="$(git remote get-url origin 2>/dev/null || echo "")"
if [ "$ACTUAL_REMOTE" != "$EXPECTED_REMOTE" ]; then
  echo "WARNUNG: Remote 'origin' weicht ab."
  echo "  Erwartet: $EXPECTED_REMOTE"
  echo "  Aktuell:  $ACTUAL_REMOTE"
  echo "  Korrigiere..."
  git remote remove origin 2>/dev/null || true
  git remote add origin "$EXPECTED_REMOTE"
fi

# === 4. Identitaet pruefen ===
if [ -z "$(git config user.email)" ] || [ -z "$(git config user.name)" ]; then
  echo "FEHLER: git user.name oder user.email nicht gesetzt."
  echo "  Loesung:"
  echo "    git config user.name  \"einsundnull\""
  echo "    git config user.email \"notorein@gmail.com\""
  exit 1
fi

# === 5. Status pruefen ===
echo "=== Git Status ==="
git status --short

# === 6. Aenderungen erkennen ===
if git diff --cached --quiet && git diff --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "Keine Aenderungen — nichts zu committen. Pruefe ob Push noetig..."
  # Trotzdem pushen falls lokaler Branch ahead ist
  if git status | grep -q "Your branch is ahead"; then
    echo "  Lokaler Branch ist remote voraus — pushe nur."
  else
    echo "  Nichts zu tun. Beende."
    exit 0
  fi
else
  # === 7. Stage + Commit ===
  echo "=== Stage + Commit ==="
  git add -A
  if ! git commit -m "$COMMIT_MSG"; then
    echo "FEHLER: Commit fehlgeschlagen. Push abgebrochen."
    exit 1
  fi
fi

# === 8. Branch sicherstellen ===
git branch -M "$BRANCH"

# === 9. Push: erst normal, dann ggf. force ===
echo "=== Push (normal) ==="
if git push origin "$BRANCH" 2>&1; then
  echo "FERTIG: Normaler Push erfolgreich."
  exit 0
fi

echo ""
echo "Normal-Push fehlgeschlagen (Remote hat ggf. abweichende Commits)."

if [ "$AUTO_YES" -eq 0 ]; then
  echo ""
  read -p "Force-Push ausfuehren? Das UEBERSCHREIBT Remote-Commits unwiderruflich! [y/N]: " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Abgebrochen. Du kannst manuell mergen mit: git pull --rebase origin $BRANCH"
    exit 1
  fi
fi

echo "=== Force-Push ==="
git push --force origin "$BRANCH"
echo "FERTIG: Force-Push erfolgreich."
