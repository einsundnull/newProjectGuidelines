# <PROJEKTNAME> — CLAUDE.md

<!--
  Diese Datei laedt Claude Code bei JEDER Session automatisch.
  Sie ist der ANKER, der dieses Projekt mit den universellen Guidelines verbindet.
  Beim Anlegen aus TEMPLATE_CLAUDE.md erzeugt; Platzhalter <…> ersetzen.
  Nicht loeschen — sonst verliert das Projekt die Anbindung an die universelle SoT.
-->

## Source of Truth #1 — Universelle Guidelines (kanonisch, NICHT kopiert)

Diese Dateien sind die verbindliche Quelle. Sie liegen ausserhalb des Projekts und
werden NIE hierher kopiert → Aenderungen dort gelten in diesem Projekt SOFORT, ohne
erneute Anweisung.

- **IMMER zu Sessionbeginn lesen:**
  `C:\Users\pc\Desktop\HTML Snippets\New Project\SESSION_PROTOCOL.md`
  (Resume §A, End-of-Iteration §B, Schritt-Statusblock §B2)
- **VOR jeder Code-Aenderung lesen:**
  `C:\Users\pc\Desktop\HTML Snippets\New Project\GUIDELINES_v2.md`
- **Bei Graph-Arbeit:**
  `C:\Users\pc\Desktop\HTML Snippets\New Project\Graphify_How_To_Use.txt`

## Source of Truth #2 — Projektspezifische Guidelines

- `<PROJEKT-ROOT-PFAD>\Guidelines\PROJECT_GUIDELINES.md`
  Ergaenzt SoT #1. Vorrang NUR bei dort explizit notiertem "PROJEKT-OVERRIDE".

## Graphify-First (Kurzform — verbindlich = SoT #1 / GUIDELINES_v2 §0)

- Zuerst `graphify-out/GRAPH_REPORT.md` lesen; Code-Fragen via
  `graphify query/explain/affected/path` gegen `graphify-out/graph.json`, statt
  Quelldateien zu durchsuchen.
- Nach Erstellen/Aendern von Funktionen den Graphen auffrischen (Scope beachten,
  GUIDELINES_v2 §0.2 — bei gefilterter Scope KEIN `graphify update .`).

## Resume / Iteration (Kurzform — verbindlich = SoT #1 / SESSION_PROTOCOL)

- Sessionstart: neueste `progress_*.txt` + `WEITERMACHEN_PROMPT.txt` lesen, Stand
  in <=4 Saetzen zusammenfassen (SESSION_PROTOCOL §A), sonst nichts.
- Nach JEDEM Schritt: neue `progress_<YYYY-MM-DD_HH-MM-SS>.txt` schreiben,
  `WEITERMACHEN_PROMPT.txt` aktualisieren, SCHRITT-STATUSBLOCK (§B2) als LETZTE
  Zeilen JEDER Antwort.
- Echte Umlaute (ä/ö/ü/ß) im Inhalt; Dateinamen ASCII.

## Projekt-Fakten (projektspezifisch ausfuellen)

- **Stack:** <z.B. Vanilla JS / ES6-Module, kein Build / Firebase / …>
- **Deploy:** <z.B. manuell vom User: git push origin main → Vercel; nur Befehl liefern>
- **Einstieg/Entry:** <z.B. index.html>
- **Besonderheiten / Graph-Scope / Ausschluesse:** <…>
