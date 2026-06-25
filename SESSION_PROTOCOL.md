# SESSION-PROTOKOLL — IMMER ZUERST LESEN

## A) RESUME (am Anfang jeder Session)

Bevor du irgendetwas anderes tust:

1. Suche im aktuellen Projektverzeichnis nach Dateien mit dem Muster
   `progress_*.txt`. Wähle die NEUESTE (höchster Timestamp im Dateinamen).
2. Lies AUSSCHLIESSLICH diese eine Datei. Lies KEINE weiteren Projektdateien,
   bis du mir den Status zusammengefasst hast.
3. Antworte mir in maximal 4 Sätzen nach diesem Schema:

   "Als Letztes haben wir daran gearbeitet: <Problem>.
    Status: <gelöst | in Arbeit | blockiert>.
    Letzter Lösungsansatz: <kurz>.
    Nächster Schritt: <nur falls Status != gelöst>."

4. Falls KEINE progress_*.txt existiert: sag genau das in einem Satz und warte
   auf meinen ersten Auftrag. Nicht nachfragen, nicht raten, nichts lesen.

## B) END-OF-ITERATION (nach jedem Durchlauf)

Sobald eine Aufgabe abgeschlossen ist (du würdest "fertig" melden) ODER ich
"weiter / commit / ok / nächste" sage, schreibst du — BEVOR du mir das
Endergebnis meldest — eine neue Datei:

  Pfad:     <Projektroot>/progress_<YYYY-MM-DD_HH-MM-SS>.txt
  Encoding: UTF-8, reiner Text (kein Markdown)
  Modus:    immer NEUE Datei, niemals eine alte überschreiben

Inhalt — genau dieses Schema, Reihenfolge nicht ändern:

  ORIGINAL-PROMPT:
  <wortwörtlich mein Auftrag, der diesen Durchlauf ausgelöst hat>

  ROOT CAUSE:
  <die eigentliche Ursache, nicht das Symptom. "unbekannt" ist erlaubt,
   "kein Fehler, neues Feature" auch.>

  LÖSUNGSVORSCHLAG:
  <was du vorgeschlagen hast, inkl. kurz erwähnter verworfener Alternativen>

  TATSÄCHLICHE LÖSUNG:
  <was am Ende implementiert wurde, mit datei:zeile-Referenzen>

  STATUS:
  <gelöst | in Arbeit | blockiert>

  NÄCHSTER SCHRITT:
  <nur ausfüllen wenn Status != gelöst, sonst leer lassen>

Zusätzlich überschreibst du die Datei `WEITERMACHEN_PROMPT.txt` im Projektroot
mit dem aktuellen Stand (Schema siehe WEITERMACHEN_PROMPT_TEMPLATE.txt).

Abschlussmeldung — PFLICHT nach jedem Durchlauf, in genau dieser Reihenfolge:

  1. "Progress-Datei erstellt unter: <pfad>"
  2. "WEITERMACHEN_PROMPT.txt aktualisiert."
  3. SCHRITT-STATUSBLOCK (siehe §B2)
  4. "Soll ich weitermachen?"

Diese Meldung ist KEINE Option — sie erfolgt immer, auch wenn der Nutzer
nicht danach fragt. Ohne diese Zeilen gilt der Durchlauf als unvollständig.

## B2) SCHRITT-STATUSBLOCK (PFLICHT am Ende JEDES Schritts)

Die LETZTEN Zeilen jeder Antwort sind IMMER dieser Block — auch ungefragt,
auch bei kleinen Fixes, auch mitten in einer mehrschrittigen Aufgabe:

  ────────────────────────── SCHRITT-STATUS ──────────────────────────
  # Schritt [n/m]: offen | erledigt
  # PD.txt (Task_*.txt) aktualisiert: ja | nein | n/a
  # progress_*.txt geschrieben: ja | nein
  # WEITERMACHEN_PROMPT.txt aktualisiert: ja | nein
  # WEITERMACHEN_PROMPT.txt bereinigt + Alt-Version archiviert: ja | nein | n/a
  # Graph aktualisiert (graphify update): ja | nein | n/a
  # Aufgabe <ID> vollständig abgeschlossen: ja | nein
  # Nächster Schritt: [n+1/m] <kurz>  bzw. nächstes TODO: <…>
  # "/clear" empfohlen: ja | nein
  #   └ Wenn ja: WEITERMACHEN_PROMPT.txt UND PD.txt MÜSSEN vorher aktuell sein.
  ─────────────────────────────────────────────────────────────────────

`n/a` nur, wenn ein Punkt sachlich nicht zutrifft (keine Funktionsänderung →
Graph `n/a`; kein Task mit ID → PD.txt `n/a`).

`/clear`-Empfehlung:
- Empfiehl `/clear`, wenn eine Aufgabe oder Teilaufgabe mit FRISCHEM Kontext
  erledigt werden KANN, oder mit frischem Kontext erledigt werden SOLLTE, um
  Token zu sparen (Kontext steht ja in WEITERMACHEN_PROMPT.txt + PD.txt).
- HARTE Vorbedingung — vor JEDEM `/clear`: WEITERMACHEN_PROMPT.txt UND PD.txt
  müssen aktuell sein. Erst speichern, dann `/clear` empfehlen.

## C) REGELN

- Eine progress_*.txt pro Durchlauf. Niemals überschreiben, niemals löschen.
- WEITERMACHEN_PROMPT.txt wird IMMER überschrieben (nur eine Datei).
- BEIDE Dateien werden nach JEDEM abgeschlossenen Arbeitsschritt geschrieben —
  nicht nur am Session-Ende. Auch nach einzelnen Fixes oder Feature-Blöcken.
- Resume-Phase darf NUR die neueste progress_*.txt + WEITERMACHEN_PROMPT.txt
  lesen — keine Codedateien, kein git log, kein README. Erst nach der
  Statuszusammenfassung darfst du weiterlesen.
- Wenn ich "weiter" sage und es gibt eine offene progress-Datei
  (Status != gelöst), arbeitest du genau an "NÄCHSTER SCHRITT" weiter — ohne
  Rückfrage.
- Timestamp = lokale Zeit beim Schreiben (nicht die Zeit aus dem Original-Prompt).
- Datum-Format strikt: `YYYY-MM-DD_HH-MM-SS` (Bindestriche in der Uhrzeit, damit
  der Dateiname auf allen Filesystemen gültig ist).
- Echte Umlaute schreiben (ä/ö/ü/ß), nicht ae/oe/ue/ss — Ausnahme: Dateinamen
  bleiben ASCII.
- GRAPHIFY-FIRST: Projektüberblick und Code-Fragen IMMER zuerst über
  `graphify-out/GRAPH_REPORT.md` + `graphify query/explain/affected` lösen, statt
  Quelldateien zu durchsuchen. Existiert kein `graphify-out/`, einmalig mit
  `/graphify .` über das ganze Projekt bauen (Müll-Ordner ausschließen).
- GRAPHIFY-UPDATE: Nach jedem Erstellen/Ändern von Funktionen `graphify update .`
  ausführen — Teil jedes Durchlaufs, bevor die Abschlussmeldung erfolgt.
- SCHRITT-STATUSBLOCK (§B2) steht am Ende JEDER Antwort — nicht nur am
  Durchlauf-Ende. Ohne ihn gilt der Schritt als unvollständig.
- `/clear` nur empfehlen, wenn WEITERMACHEN_PROMPT.txt UND PD.txt aktuell sind
  (harte Vorbedingung, siehe §B2).
- Am Ende immer melden: siehe Abschlussmeldung oben (§ B).

## D) GUIDELINES

Vor jeder Code-Änderung gelten die Regeln aus `GUIDELINES_v2.md`
unter "C:\Users\pc\Desktop\HTML Snippets\New Project\" (oder projektspezifische docs\guidelines\PROJECT_GUIDELINES.md). Wenn ein Punkt im Konflikt
mit bestehendem Projektcode steht: bestehenden Code respektieren, neue
Code-Teile nach Guideline schreiben, Konflikt im progress-Log notieren.
