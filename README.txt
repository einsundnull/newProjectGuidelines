==============================================================================
NEW PROJECT — Universelle Guidelines- und Vorlagen-Quelle (Source of Truth #1)
==============================================================================

Zweck:
  Dieser Ordner ist die EINE kanonische Quelle fuer universelle Regeln, die fuer
  JEDES Claude-Projekt gelten. Projekte kopieren diese Regeln NICHT, sondern
  verweisen darauf — Aenderungen hier wirken automatisch in allen Projekten.

==============================================================================
EINSTIEG — neues Projekt (nur EINE Datei noetig)
==============================================================================
Sage zu Claude EINMAL im Projektordner:

  Lies "C:\Users\pc\Desktop\HTML Snippets\New Project\Lies Mich um ein neues
  Projekt zu starten.txt" und richte das aktuelle Projekt danach ein.

Claude liest dann SoT #1, legt im Projekt CLAUDE.md (Anker) + Guidelines\
PROJECT_GUIDELINES.md + WEITERMACHEN_PROMPT.txt an und baut ggf. den Graphen.
Danach reagiert das Projekt dauerhaft nach denselben Guidelines.

==============================================================================
ZWEI SOURCES OF TRUTH
==============================================================================
SoT #1 — UNIVERSELL (dieser Ordner; gilt fuer alle Projekte):
  Lies Mich um ein neues Projekt zu starten.txt
      → Die EINZIGE Einstiegsdatei. Sagt Claude alles zum Projektstart.
  SESSION_PROTOCOL.md
      → Spielregeln: Resume §A, End-of-Iteration §B, Schritt-Statusblock §B2.
  GUIDELINES_v2.md
      → Code/Layout/Architektur/Graphify-Regeln fuer allen neuen Code.
  Graphify_How_To_Use.txt
      → Knowledge-Graph-Bedienung (Token sparen).
  WEITERMACHEN_PROMPT_TEMPLATE.txt
      → Vorlage fuer <Projekt>\WEITERMACHEN_PROMPT.txt.
  TEMPLATE_CLAUDE.md
      → Vorlage fuer <Projekt>\CLAUDE.md = der AUTO-PROPAGATIONS-ANKER, der das
        Projekt mit SoT #1 verbindet (Claude Code laedt CLAUDE.md jede Session).
  TEMPLATE_PROJECT_GUIDELINES.md
      → Vorlage fuer <Projekt>\Guidelines\PROJECT_GUIDELINES.md (= SoT #2).

SoT #2 — PROJEKTSPEZIFISCH (im jeweiligen Projektordner):
  <Projekt>\Guidelines\PROJECT_GUIDELINES.md
      → Ergaenzt SoT #1; Vorrang nur bei explizitem "PROJEKT-OVERRIDE".

==============================================================================
WARUM AENDERUNGEN AUTOMATISCH ueberall GREIFEN
==============================================================================
- Jedes Projekt hat ein <Projekt>\CLAUDE.md (aus TEMPLATE_CLAUDE.md). Claude Code
  laedt es bei jeder Session automatisch. Es VERWEIST auf SESSION_PROTOCOL.md +
  GUIDELINES_v2.md in DIESEM Ordner (keine Kopie).
- Aendert man hier eine Regel, liest Claude in der naechsten Session jedes Projekts
  automatisch die neue Fassung. Kein Nachziehen, keine Drift.
- Universelle Regeln: NUR hier aendern. Projektspezifisches: NUR in
  <Projekt>\Guidelines\PROJECT_GUIDELINES.md.

==============================================================================
BESTEHENDE SESSION FORTSETZEN
==============================================================================
- Claude Code im Projektordner oeffnen → <Projekt>\CLAUDE.md laedt automatisch.
- Zum gezielten Fortsetzen den Inhalt von <Projekt>\WEITERMACHEN_PROMPT.txt als
  ersten Prompt einfuegen. Claude liest nur SoT #1 (SESSION_PROTOCOL/GUIDELINES) +
  neueste progress_*.txt + WEITERMACHEN_PROMPT.txt und macht dort weiter.

==============================================================================
BESTEHENDES PROJEKT NACHRUESTEN (optional)
==============================================================================
Damit ein ALTES Projekt ebenfalls automatisch SoT #1 folgt: in dessen
<Projekt>\CLAUDE.md den Block "Source of Truth #1" aus TEMPLATE_CLAUDE.md ergaenzen
(Verweise auf SESSION_PROTOCOL.md + GUIDELINES_v2.md). Danach gilt SoT #1 dort
ebenfalls automatisch.

==============================================================================
WICHTIG
==============================================================================
- progress_*.txt nie loeschen/ueberschreiben — nur WEITERMACHEN_PROMPT.txt wird
  ueberschrieben.
- Dateinamen/Pfade ASCII (ae/oe/ue/ss). Inhalt (Texte, Kommentare, Logs): echte
  Umlaute ä/ö/ü/ß.
- START_PROMPT.txt + Start-a-new-Project_LEGACY.txt sind die ALTE (Paste-Prompt-)
  Methode — weiterhin nutzbar, aber "Lies Mich …" ist der neue, einfachere Weg.
==============================================================================
