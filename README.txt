==============================================================================
NEW_PROJECT — Vorlagen- und Regel-Ordner
==============================================================================

Zweck:
  Dieser Ordner enthält alle Dateien, die jedes neue Claude-Projekt mit
  Guidelines, Progress-Log und Resume-Mechanismus ausstatten.

Inhalt:
  START_PROMPT.txt
      → Universeller Start-Prompt für JEDES neue Projekt.
        Einmal ändern: Projekt-Pfad einsetzen. Dann 1:1 in Claude einfügen.

  WEITERMACHEN_PROMPT_TEMPLATE.txt
      → Vorlage für die WEITERMACHEN_PROMPT.txt, die in jedem Projekt-Root
        liegt und nach jeder Iteration aktualisiert wird.

  SESSION_PROTOCOL.md
      → Die Spielregeln (RESUME / END-OF-ITERATION / Datei-Format).
        Wird vom START_PROMPT referenziert.

  UNIVERSAL_GUIDELINES.md
      → Layout / Architektur / Simple / Premium Guidelines.
        Gelten für allen neu geschriebenen Code.

==============================================================================
WORKFLOW — neues Projekt anlegen
==============================================================================

1. Lege deinen Projekt-Ordner an, z.B.:
     C:\Users\pc\Documents\MeinNeuesProjekt

2. Öffne Claude Code in diesem Ordner.

3. Öffne START_PROMPT.txt, ersetze einmalig
     <HIER PROJEKTPFAD EINSETZEN>
   durch den echten Pfad, kopiere den ganzen Text und füge ihn als ersten
   Prompt in Claude ein.

4. Claude wird:
   - SESSION_PROTOCOL.md + UNIVERSAL_GUIDELINES.md lesen
   - WEITERMACHEN_PROMPT_TEMPLATE.txt einmalig in deinen Projekt-Root
     kopieren als WEITERMACHEN_PROMPT.txt
   - Bei jeder Iteration:
       a) progress_<YYYY-MM-DD_HH-MM-SS>.txt im Projekt-Root anlegen
       b) WEITERMACHEN_PROMPT.txt im Projekt-Root überschreiben

==============================================================================
WORKFLOW — bestehendes Projekt fortsetzen (z.B. neue Claude-Session)
==============================================================================

1. Öffne im Projekt-Root die Datei WEITERMACHEN_PROMPT.txt.
2. Kopiere ihren kompletten Inhalt.
3. Füge ihn als ersten Prompt in der neuen Claude-Session ein.
   → Claude liest nur SESSION_PROTOCOL.md + UNIVERSAL_GUIDELINES.md
     + die neueste progress_*.txt + WEITERMACHEN_PROMPT.txt selbst
     und macht dort weiter, wo du aufgehört hast.

==============================================================================
WICHTIG
==============================================================================

- Niemals progress_*.txt löschen oder überschreiben — nur WEITERMACHEN_PROMPT.txt
  wird überschrieben.
- Bei Pfad-/Dateinamen Umlaute IMMER als ae/oe/ue/ss schreiben.
- Im Inhalt (Texten, Code-Kommentaren, Logs) Umlaute IMMER echt: ä/ö/ü/ß.
- Wenn ein Projekt eigene Guidelines hat, lege sie als
  PROJECT_GUIDELINES.md in den Projekt-Root — die ergänzen UNIVERSAL_GUIDELINES.md
  (überschreiben sie nicht stillschweigend).

==============================================================================
