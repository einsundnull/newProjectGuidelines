# Universelle Projekt-Guidelines

> Version 2 — ergänzt um Domain-Layer-Trennung, i18n-Fallback-Pflicht, Google-Login-Best-Practice, Accessibility, CSP und Build/Test-Vorgaben.

## 0. Knowledge Graph (Graphify) — von Anfang an

### 0.1 Grundsatz
- Jedes Projekt wird von Beginn an mit **Graphify** erfasst. Der Knowledge-Graph
  ist die primäre Quelle für Projektüberblick und Code-Navigation — **nicht** das
  reihenweise Lesen der Quelldateien (Token-Ersparnis).
- Der Graph erfasst das **ganze Projekt** als eine Map aus **HTML + JS + CSS**.

### 0.2 Bauen & Aktualisieren
- Initialer Bau beim ersten Lauf: `/graphify .` (kleines/mittleres Projekt).
  Müll-Ordner immer ausschließen: `node_modules`, `.git`, `graphify-out`, `Doc`,
  `*Kopie*`, `*backup*`, `locales`.
- Sehr große Projekte (>500 Dateien): nicht blind `/graphify .`, sondern auf die
  Quell-Ordner scopen (z.B. `js` + `*.html`), Archiv-/Doc-Ordner draußen lassen.
- **Pflicht: Nach jedem Erstellen oder Ändern von Funktionen** den Graphen
  auffrischen. ABER: `graphify update .` respektiert eine gefilterte Scope
  NICHT — es re-extrahiert das ganze Verzeichnis (inkl. Legacy/Archiv) und
  bläht den Graphen auf. Daher:
  - Projekt OHNE Ausschlüsse (alles im Graph): `graphify update .` ist ok.
  - Projekt MIT gefilterter Scope: KEIN `graphify update .` — entweder gezielt
    `graphify update <einzelne-datei.js>` (nur AST) oder den manuellen
    gefilterten Rebuild (detect → Liste filtern → AST → semantischer Pass →
    build → export). Voller Rebuild ohnehin nach großen Strukturänderungen.
  - Reine Inline-JS-Änderungen in HTML erfasst der AST-Update nicht (HTML läuft
    nur durch den semantischen Pass) — für kleine HTML-Helper lohnt oft kein Rebuild.
  - Graphify legt vor jedem Update ein Backup unter `graphify-out/<DATUM>/` an.

### 0.3 GRAPHIFY-FIRST (Lesereihenfolge)
1. Zuerst `graphify-out/GRAPH_REPORT.md` lesen (God-Nodes, Communities, Zyklen).
2. Konkrete Fragen über die Graph-CLI gegen `graphify-out/graph.json`:
   `graphify query "..."` / `explain "X"` / `affected "X"` / `path "A" "B"`.
3. Einzelne Quelldateien nur öffnen, wenn der Graph nicht ausreicht oder Code
   tatsächlich geändert wird.
- `graph.json` (groß) nie komplett in den Chat lesen — nur per CLI abfragen.

### 0.4 Verankerung (keine erneute Klärung nötig)
- Diese Regel gilt automatisch für jedes Projekt. Einstieg = EINE Datei:
  „Lies Mich um ein neues Projekt zu starten.txt" im New-Project-Ordner.
- Beim Anlegen erzeugt Claude im Projektroot eine `CLAUDE.md` aus
  `TEMPLATE_CLAUDE.md`. Diese ist der **Auto-Propagations-Anker**: Claude Code
  lädt sie bei jeder Session automatisch, und sie VERWEIST (keine Kopie) auf die
  universelle Source of Truth #1 in
  `C:\Users\pc\Desktop\HTML Snippets\New Project\` (SESSION_PROTOCOL.md +
  GUIDELINES_v2.md + Graphify_How_To_Use.txt) sowie auf die projektspezifische
  SoT #2 (`<Projekt>\Guidelines\PROJECT_GUIDELINES.md`).
- Folge: Änderungen an diesen universellen Dateien gelten ab der nächsten Session
  in ALLEN Projekten automatisch — ohne erneute Anweisung, ohne Nachziehen von
  Kopien. GRAPHIFY-FIRST ist Teil dieser Anbindung (Kurzform im CLAUDE.md,
  verbindlich = dieses §0). (START_PROMPT.txt = ältere Paste-Methode, weiter gültig.)

## 0.5 Schritt-Statusblock (PFLICHT am Ende JEDES Schritts)

Die **letzten Zeilen jeder Antwort** sind IMMER dieser Block — auch ungefragt,
auch bei kleinen Fixes. Fehlt der Block, gilt der Schritt als unvollständig.

```
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
```

**Regeln zum Block:**
- `n/a` nur, wenn der Punkt für diesen Schritt sachlich nicht zutrifft
  (z.B. keine Funktionsänderung → Graph `n/a`; kein Task mit ID → PD.txt `n/a`).
- "Graph aktualisiert" folgt der Update-Regel aus §0.2 (gefilterte Scope ≠
  `graphify update .`).

**`/clear`-Empfehlung:**
- Du empfiehlst `/clear`, wenn eine Aufgabe oder Teilaufgabe mit **frischem
  Kontext** erledigt werden KANN, oder mit frischem Kontext erledigt werden
  SOLLTE, um **Token zu sparen** (ohne Kontextverlust, weil der Stand in
  WEITERMACHEN_PROMPT.txt + PD.txt steht).
- **Harte Vorbedingung — vor JEDEM `/clear`:** WEITERMACHEN_PROMPT.txt UND
  PD.txt müssen auf aktuellem Stand sein. Erst speichern, dann `/clear`
  empfehlen. Niemals `/clear` empfehlen, solange einer der beiden veraltet ist.

## 1. Architektur

### 1.1 Schichtenmodell
- User Interface Layer, Client Layer, Service Layer und Domain Layer sind strikt voneinander getrennt.
- Die Client Layer darf niemals direkt auf Datenbanken, Cloud-Dienste oder externe Persistenzsysteme zugreifen.
- Sämtliche Zugriffe auf Datenquellen erfolgen ausschließlich über Service Layer → Domain Layer.

### 1.2 Aufgaben der Service Layer (bewusst schlank)
Die Service Layer übernimmt **ausschließlich** drei Aufgaben:

- **Routing** — entscheidet, wohin eine Anfrage geht (z. B. `/login` → Login-Seite, `/api/user` → User-Service). Reine Wegfindung, keine inhaltliche Bewertung.
- **Validierung** — prüft, ob eingehende Daten *formal* korrekt sind (E-Mail-Format, Passwortlänge, Pflichtfelder). Reiner Datencheck, keine Geschäftsregel.
- **Authentifizierung** — stellt fest, *wer* die Anfrage stellt (Passwort, Google Login, Passkey, 2FA). Reiner Identitätscheck, keine Berechtigungsentscheidung über Geschäftsvorgänge.

Diese drei Aufgaben bleiben strikt von der eigentlichen Geschäftslogik getrennt. Vermischung führt zu Sicherheits- und Wartungsproblemen.

### 1.3 Domain Layer (Geschäftslogik)
- Geschäftsregeln, Berechnungen, Workflows und fachliche Entscheidungen leben ausschließlich in der Domain Layer.
- Die Domain Layer liegt zwischen Service Layer und Datenpersistenz und wird ausschließlich von der Service Layer aufgerufen — niemals direkt vom Client.
- Dadurch bleibt die Service Layer dauerhaft schlank (1.2), weil sie nur Weg, Datencheck und Identität trägt, nicht die fachliche Logik selbst.

### 1.4 Single Source of Truth
- Mock-up und finale Implementierung verwenden dieselbe Source of Truth für Styling, Layout und Architektur.
- Doppelte Definitionen sind zu vermeiden.

### 1.5 Cloud- und Datenbankzugriffe
- Jeder Zugriff auf Cloud-Dienste oder Datenbanken erfolgt ausschließlich über Service Layer → Domain Layer.
- Vor jedem Zugriff erfolgt eine Verifizierung über Cloudflare (konkrete Stufe — z. B. Zero Trust Access, WAF-Regelwerk oder Turnstile — wird pro Projekt in `docs/architecture` dokumentiert, inklusive der Frage, ob die Prüfung pro Request oder pro Session erfolgt).
- Direkte Client-zu-Datenbank-Verbindungen sind verboten.
- Direkte Client-zu-Cloud-Verbindungen sind verboten, sofern keine dokumentierte Ausnahme vorliegt.

## 2. HTML-, CSS- und JavaScript-Regeln

### 2.1 Strikte Trennung
- HTML, CSS und JavaScript müssen strikt getrennt sein.
- Inline-Styles sind nicht erlaubt.
- Inline-JavaScript ist nicht erlaubt.

### 2.2 UI-Erzeugung
- Alle User-Interface-Elemente werden zunächst statisch in HTML erzeugt.
- Dynamische Änderungen erfolgen ausschließlich nachträglich über JavaScript.
- Falls eine Inline-JavaScript-Implementierung notwendig erscheint: vorher Zustimmung einholen und begründen. Nur extrem gute Gründe (massive Performance-Einschränkung, massives Sicherheitsrisiko) rechtfertigen das Brechen dieser Regel.

### 2.3 Mock-up-Pflicht
- Vor der Implementierung eines neuen UI-Elements wird immer ein HTML-Mock-up erstellt. Ziel: Nach Freigabe dürfen zwischen Mock-up und Implementierung keine Unterschiede in Layout/Styling auftreten.
- Gilt für: Seiten, Dialoge, Formulare, Navigationselemente, Buttons, Icons, einzelne UI-Komponenten.

## 3. Internationalisierung (i18n)

### 3.1 Grundsatz
- Jeder für den Nutzer sichtbare UI-Text wird von Anfang an über einen i18n-Key abgebildet — niemals Hardcoded-Text im Markup, auch nicht in Dialogen, Alerts oder Toasts.
- Standard-/Fallback-Sprache ist Deutsch.

### 3.2 Namespace & Struktur
- Der Namespace einer i18n-Datei entspricht immer dem Namen der `.html`-Seite, auf der der Text angezeigt wird.
- Wird ein Dialog/Alert/Toast von einer Seite ausgelöst, gilt der Namespace der auslösenden Seite — nicht ein eigener Dialog-Namespace.
- Die Hierarchie innerhalb der JSON-Dateien bleibt so flach wie möglich, im Idealfall genau eine Ebene (`"button_login": "Anmelden"` statt verschachtelter Objekte).

### 3.3 Fallback-Kette (verpflichtend)
Reihenfolge bei der Auflösung eines Keys:

1. Angeforderte Sprache des Nutzers.
2. Deutsch (Default).
3. **Niemals** der rohe technische Key als sichtbarer Text.

Es darf zu keinem Zeitpunkt — auch nicht nach einem Hard-Reset/ersten Laden ohne Cache — sichtbar werden, dass z. B. `button_token_login` statt eines übersetzten Textes angezeigt wird.

### 3.4 Technische Absicherung
- Die deutschen Default-Übersetzungen werden **synchron mit der Seite ausgeliefert** (inline im initialen HTML/JS, nicht asynchron nachgeladen). Dadurch ist beim ersten Paint — auch direkt nach Hard-Reset, vor dem Laden einer anderen Sprache — immer ein korrekter Text vorhanden.
- Die i18n-Funktion gibt bei einem fehlenden Key niemals den Key selbst zurück, sondern fällt automatisch auf Deutsch zurück.
- Build-/CI-Check: Ein Lint-Schritt vergleicht alle im Code verwendeten i18n-Keys mit den vorhandenen JSON-Namespaces. Der Build schlägt fehl, wenn ein verwendeter Key in der deutschen Default-Datei fehlt. Damit ist das Auftreten eines rohen Keys zur Laufzeit strukturell ausgeschlossen, nicht nur durch Konvention vermieden.

## 4. Barrierefreiheit (Accessibility)

### 4.1 Grundsatz
- Barrierefreiheit ist kein nachträglicher Schritt, sondern Teil der Mock-up-Prüfung (2.3).

### 4.2 Fokus & Tastatur
- Jedes interaktive Element ist per Tastatur erreichbar und besitzt einen sichtbaren Fokus-Zustand (auch bei borderless Buttons, siehe 6.4).
- Dialoge/Overlays trappen den Fokus während der Anzeige und geben ihn beim Schließen an das auslösende Element zurück (Details: 7.3).

### 4.3 Farbe & Kontrast
- Farbe ist niemals der alleinige Indikator für einen Zustand (Fehler, Erfolg, Warnung) — immer zusätzlich Icon oder Text.
- Text-/Hintergrundkombinationen erfüllen WCAG AA (mind. 4,5:1 für Fließtext, 3:1 für große Schrift). Vor Festlegung der zweiten UI-Farbe (6.3) wird das Kontrastverhältnis geprüft und in `docs/decisions` dokumentiert.

### 4.4 Bewegung
- Alle Animationen (insbesondere die Flight-In-Animation des Menüs, 6.2) respektieren `prefers-reduced-motion`. Bei aktivierter Einstellung wird direkt eingeblendet, ohne Übergangsanimation.

## 5. Dokumentation

### 5.1 Ablageort
Folgende Artefakte werden im Dokumentationsverzeichnis abgelegt: HTML-Mock-ups (`mockups`), Progress-Dateien (`progress`), Dokumentationen (`doc`), Architektur-Dokumente, UI-Spezifikationen, Ausnahmegenehmigungen, technische Entscheidungen.

### 5.2 Ausnahmen
- Jede Ausnahme von den Guidelines wird dokumentiert.
- Ausnahmen werden als Code-Kommentar **und** zusätzlich in der Dokumentation festgehalten.
- Jede Ausnahme benötigt eine technische Begründung.

## 6. Design-System

### 6.1 Schriftarten
- Standardschriftart: Figtree. Alternative: Victory.
- Alle Schriftarten werden lokal bereitgestellt, keine externen Font-CDNs, keine durch Font-Einbindung erzeugten Cookies.
- Vor dem Self-Hosting wird die Lizenz beider Schriftarten geprüft (Self-Hosting-Erlaubnis erforderlich); Ergebnis wird in `docs/decisions` festgehalten.

### 6.2 Typografie
- Maximal vier unterschiedliche Schriftgrößen projektweit, alle durch 4 px oder 8 px teilbar.
- Beschriftungen kurz halten ("Klicke hier zum Anmelden" → "Anmelden").

### 6.3 Farben
- Maximal zwei Schriftfarben projektweit. Bevorzugte Schriftfarbe: Magnetic (`#090099`).
- Maximal zwei Farben für die UI-Hierarchie: `#ffffff` und `<custom>`.
- Farbvarianten ausschließlich durch Tint und Shade erzeugen. Status-Zustände (Fehler/Erfolg/Warnung) werden als Tint/Shade dieser Basisfarben abgeleitet und immer mit Icon/Text kombiniert (4.3).

### 6.4 Buttons
- Buttons in Navbar, Hamburger-Menü und Footer sind borderless, behalten aber einen sichtbaren Fokus-Indikator (4.2).

### 6.5 Icons
- Icons werden bevorzugt verwendet, Emojis sind nicht erlaubt. Jedes Icon erhält einen zugänglichen Text (`aria-label` oder versteckten Text), sofern es nicht rein dekorativ ist.

### 6.6 Gradienten
- Gradienten sind grundsätzlich verboten. Ausnahmen müssen erfragt und per Kommentar dokumentiert werden.

### 6.7 Responsive Design
- Breakpoints werden zentral als Design-Token definiert (z. B. eigene `breakpoints.css`) und projektweit einheitlich verwendet — keine seitenindividuellen Breakpoints.

## 7. Dialog-, Overlay- und Toast-System

### 7.1 Basisklassen
Für jede Komponentengruppe existiert genau eine gemeinsame Basisklasse: `base-class-dialogs`, `base-class-toasts`, `base-class-overlay`, `base-class-navbar`, `base-class-footer`, `base-class-menu`, `base-class-buttons`, `base-class-navbar-buttons`, `base-class-menu-buttons`, `base-class-<name>` für Custom-UI-Elemente.

### 7.2 Vererbung
- Alle konkreten Dialoge/Toasts/Overlays erben von ihrer jeweiligen Basisklasse. Alle Standard-Buttons erben von `base-class-buttons`. Alle UI-Elemente erben von ihrer Basisklasse, sofern diese existiert.

### 7.3 Barrierefreiheit der Dialoge
- Technische Basis ist das native `<dialog>`-Element (`HTMLDialogElement`) statt einer reinen `<div>`-Konstruktion. Es bringt Fokus-Trapping, ESC-Schließen und korrektes Layering von Haus aus mit und wird vollständig über `base-class-dialogs` gestylt. Das verstößt nicht gegen "keine Standarddialoge" — diese Regel betrifft die visuelle Standardoptik des Browsers, nicht das semantische HTML-Element darunter.
- `role="dialog"` bzw. `role="alertdialog"` für blockierende Fehlermeldungen, `aria-modal="true"`, `aria-labelledby`/`aria-describedby` auf Titel und Text.
- Fokus wird beim Öffnen auf das erste interaktive Element gesetzt und beim Schließen an das auslösende Element zurückgegeben.
- ESC schließt jeden Dialog/jedes Overlay, sofern kein destruktiver Vorgang aktiv läuft.

### 7.4 Fehlersichtbarkeit aus Overlays
- Da Overlays häufig keine sichtbaren Debug-Logs liefern, öffnet ein Fehler innerhalb eines Overlays/Dialogs einen eigenen Error-Dialog (Basis: `base-class-dialogs`, `role="alertdialog"`) mit einem für Screenreader zugänglichen Text. Der Fehlertext nutzt denselben i18n-Namespace wie die auslösende Seite (3.2).

## 8. Navigation

### 8.1 Universelle Navigation
- Es existiert genau eine universelle Navigationsbar.

### 8.2 Hamburger-Menü
- Rechts befindet sich ein Hamburger-Menü-Icon-Button, der ein Menü als Flight-In-Animation von rechts nach links öffnet (Basisklasse 7.1; Reduced-Motion siehe 4.4).
- Der Button trägt `aria-expanded` (true/false) und `aria-controls`, das auf das Menü verweist.

### 8.3 Menüstruktur
- Menüpunkte werden vertikal, top to bottom, angeordnet. Konkrete Menüpunkte werden projektspezifisch definiert.

## 9. Footer und rechtliche Anforderungen

### 9.1 Universeller Footer
- Jede HTML-Seite enthält denselben Footer als Bestandteil des gemeinsamen Layout-Systems, nicht individuell pro Seite implementiert.

### 9.2 Pflichtlinks
Mindestens: Impressum, Datenschutzerklärung, Cookie-Policy, AGB, Kontakt, Widerrufsbelehrung (falls erforderlich), weitere rechtlich erforderliche Dokumente.

### 9.3 Einheitlichkeit
- Alle Seiten verwenden dieselbe Footer-Komponente, Änderungen erfolgen zentral.

## 10. Authentifizierung und Sicherheit

### 10.1 Zwei-Faktor-Authentifizierung
- Jede Anmeldung erfordert verpflichtend eine zweite Authentifizierungsstufe — auch bei E-Mail/Passwort, Google Login und weiteren Identity Providern.
- **Begründung (gemäß 5.2-Pflicht zur Dokumentation von Regeln mit Mehraufwand):** Der MFA-Status eines Nutzerkontos beim Identity Provider ist für die Relying Party nicht zuverlässig abfragbar. Eine projekteigene zweite Stufe ist der einzige Weg, eine garantierte zweite Faktor-Prüfung sicherzustellen, unabhängig davon, ob der Nutzer bei Google MFA aktiviert hat.

### 10.2 Bevorzugte Verfahren
1. Passkeys (WebAuthn/FIDO2)
2. Authenticator-App (TOTP)
3. Hardware Security Key
4. E-Mail-Einmalcode

### 10.3 Nicht bevorzugte Verfahren
- SMS-basierte 2FA nur als Fallback.

### 10.4 Session-Sicherheit
- HTTPS-Pflicht, Secure Sessions, CSRF-Schutz, Rate Limiting, Cloudflare-Schutz vor Authentifizierung.
- CSRF-Schutz ist primär relevant für den Cookie-Anteil der Session (Refresh-Token, siehe 11.2.1). Bei reinem Header-Token-Transport (Access Token) ist CSRF strukturell entschärft, da der Browser den Token nicht automatisch mitsendet.

### 10.5 Google Login (Best Practice)
- Implementierung über **Google Identity Services (GIS)** — die ältere `gapi.auth2`-Bibliothek ("Google Sign-In") ist veraltet und wird nicht mehr verwendet.
- Seit August 2025 ist **FedCM** (Federated Credential Management) für One-Tap- und Sign-In-Button-Implementierungen in Chrome verpflichtend; GIS übernimmt die Umstellung automatisch.
- FedCM löst die Anmeldung über eine browserseitig vermittelte API anstelle von Drittanbieter-Cookies — das passt strukturell zur Cookie-freien Architektur (Abschnitt 11) und wird entsprechend dokumentiert statt als Ausnahme behandelt.
- FedCM gilt nach Einschätzung von Google selbst als Zugriff auf im Endgerät gespeicherte Informationen und unterliegt damit grundsätzlich der ePrivacy-Einwilligungspflicht in EU/EWR/UK — Ausnahme, wenn die Nutzung technisch notwendig für den vom Nutzer ausdrücklich angeforderten Dienst ist (hier: aktiv ausgelöster Login-Button). Diese Einschätzung wird je Projekt dokumentiert (5.2/12.5).
- Safari unterstützt FedCM aktuell nicht, Firefox befindet sich im Rollout. Für Browser ohne FedCM-Unterstützung ist ein Fallback auf den klassischen OAuth-2.0-Redirect-Flow (Authorization Code mit PKCE) vorzusehen.
- Das von Google ausgestellte ID-Token wird ausschließlich serverseitig in der Service Layer verifiziert (Signatur, Audience, Issuer, Nonce gegen Replay) — niemals client-seitig vertrauen.
- Ein erfolgreicher Google Login ist ein Identitätsnachweis, kein Autorisierungsnachweis für Geschäftsvorgänge. Nach Verifizierung erfolgt die eigene Session-/Token-Ausstellung gemäß Abschnitt 11, plus die zweite Faktor-Stufe gemäß 10.1.

## 11. Cookie-freie Architektur

### 11.1 Grundsatz
- Das System wird grundsätzlich cookie-frei entwickelt.

### 11.2 Bevorzugte Verfahren
- JWT Access Tokens im Arbeitsspeicher, kurzlebig (5–15 Minuten), Token Rotation, WebAuthn/Passkeys, serverseitige Sessions ohne Browser-Cookies, sofern technisch möglich.

#### 11.2.1 Persistenz über Page-Reloads (Entscheidung)
Reiner Arbeitsspeicher überlebt keinen Page-Reload. Damit nach einem Reload keine erneute vollständige Anmeldung nötig ist, gilt folgende festgelegte Strategie:
- Der **Refresh Token** wird als `httpOnly` + `Secure` + `SameSite=Strict`-Cookie ausgeliefert.
- Dieses Cookie ist technisch notwendig (Session-Aufrechterhaltung) und kein Tracking-Cookie — es fällt unter die Ausnahme aus 12.3/13.4 und benötigt deshalb kein Consent-Banner.
- Der **Access Token** bleibt ausschließlich im Arbeitsspeicher (nie in `localStorage`/`sessionStorage`) und wird über den Authorization-Header übertragen.
- Diese Ausnahme vom reinen Cookie-frei-Grundsatz wird gemäß 5.2/13.5 dokumentiert: Zweck (Session-Persistenz), Speicherdauer (Lebensdauer des Refresh Tokens), technische Notwendigkeit, verantwortlicher Dienst.

### 11.3 Drittanbieter
- Drittanbieter dürfen keine Tracking-Cookies erzeugen. Externe Fonts, externe Tracking-Skripte und externe Analyse-Tools mit Cookie-Erzeugung sind verboten.

### 11.4 Firebase und ähnliche Plattformen
- Vor Einsatz prüfen: Werden Cookies erzeugt? Sind sie technisch notwendig? Gibt es eine cookie-freie Alternative?

### 11.5 Ausnahmeverfahren
- Falls Cookies technisch unvermeidbar sind: Ausnahme, technische Begründung und rechtliche Prüfung dokumentieren (siehe 11.2.1 als bereits dokumentiertes Beispiel).

## 12. Cookie-Policy

### 12.1 Grundsatz
- Die Cookie-Policy wird im Footer verlinkt.

### 12.2 Standardaussage
- Das Projekt verwendet grundsätzlich keine Cookies außer den dokumentierten technisch notwendigen Ausnahmen (11.2.1).

### 12.3 Ausnahmen
- Technisch notwendige Cookies werden vollständig dokumentiert: Zweck, Speicherdauer, technische Notwendigkeit, verantwortlicher Dienst.

### 12.4 Zielsetzung
- Die Architektur wird so gestaltet, dass kein Cookie-Banner erforderlich ist. Banner sind nur zulässig, wenn technische oder rechtliche Anforderungen dies zwingend erfordern.

## 13. Sicherheits-Header (CSP)

### 13.1 Grundsatz
- Da Inline-CSS und Inline-JavaScript projektweit verboten sind (2.1), wird diese Trennung serverseitig über eine strikte Content-Security-Policy technisch erzwungen statt nur als Konvention zu bestehen.
- Mindestkonfiguration: `script-src 'self'`, `style-src 'self'`, `object-src 'none'`, `base-uri 'self'`, `frame-ancestors 'self'`.
- Für Drittanbieter (z. B. Google Identity Services, 10.5) werden ausschließlich die konkret benötigten Quellen ergänzt — keine pauschale Öffnung.
- CSP-Verstöße werden serverseitig geloggt (`report-to`/`report-uri`), um versehentliche Inline-Verstöße früh zu erkennen.

## 14. CSS-Organisation

### 14.1 Grundsatz
- Jedes individuell gestaltete UI-Element erhält eine eigene CSS-Datei, eindeutig einem UI-Element zugeordnet. Keine Sammel-CSS-Dateien.

### 14.2 Namenskonvention
Format: `<seite>_<ui-element>.css` — Beispiele: `index_header-button-left.css`, `login_google-login-button.css`.

### 14.3 Wiederverwendbare Komponenten
`shared_navigation.css`, `shared_footer.css`, `shared_dialog.css`, `shared_overlay.css`, `shared_toast.css`.

### 14.4 Verantwortlichkeit
- Jede CSS-Datei enthält ausschließlich Styling der referenzierten Komponente, keine Seiteneffekte.

### 14.5 Design-Tokens
Zentrale Dateien: `colors.css`, `typography.css`, `spacing.css`, `animations.css`, `z-index.css`, `breakpoints.css` (6.7). Hardcodierte Werte sind zu vermeiden.

## 15. Komponenten-Dateistruktur

### 15.1 Grundsatz
Jede Komponente besteht aus `<seitenname>_<komponente>.html`, `.css` und `.js` mit identischem Basisnamen.

### 15.2 Kapselung
- Komponenten dürfen keine fremden Komponenten manipulieren. Kommunikation erfolgt ausschließlich über definierte Schnittstellen.

## 16. JavaScript-Organisation

### 16.1 Namenskonvention
Format: `<seitenname>_<komponente>.js`.

### 16.2 Verantwortlichkeit
Erlaubt: Event-Handling, Rendering, Zustandsverwaltung, Kommunikation mit der Service Layer.
Nicht erlaubt: direkte Datenbank-/Cloudzugriffe, Geschäftslogik (liegt in der Domain Layer, 1.3), Styling.

## 17. Build, Tooling und Tests

### 17.1 Build
- Trotz der 1-Datei-pro-Komponente-Regel (15) werden CSS/JS für die Produktion über einen Bundler (z. B. Vite/esbuild) zusammengefasst und minifiziert, um die Anzahl der HTTP-Requests gering zu halten. Die Trennung gilt für den Quellcode, nicht zwingend für das Auslieferungsartefakt.

### 17.2 Tests
- Jede Komponente erhält mindestens einen automatisierten Unit-Test ihrer JavaScript-Logik. Testdateien folgen demselben Namensschema mit Suffix `.test.js` und liegen co-located neben der Komponente (passend zur Kapselung aus 15.2).
- Kritische Abläufe (Login, Zahlungsfluss, Dialog-Öffnen/Schließen) erhalten zusätzlich einen Integrationstest.
- Die i18n-Vollständigkeit wird über den Lint-Check aus 3.4 abgesichert.

## 18. Verzeichnisstruktur

```
project/
│
├── docs/
│   ├── mockups/
│   ├── progress/
│   ├── architecture/
│   ├── decisions/
│   └── exceptions/
│
├── i18n/
│   └── de/
│       ├── index.json
│       ├── login.json
│       └── dashboard.json
│
├── ui/
│   ├── shared/
│   │   ├── navigation/
│   │   ├── footer/
│   │   ├── dialog/
│   │   ├── overlay/
│   │   └── toast/
│   ├── index/
│   ├── login/
│   ├── dashboard/
│   └── settings/
│
├── css/
│   ├── tokens/
│   │   ├── colors.css
│   │   ├── typography.css
│   │   ├── spacing.css
│   │   ├── animations.css
│   │   ├── z-index.css
│   │   └── breakpoints.css
│   └── components/
│
├── js/
│   ├── services/      (Frontend-Module: Kommunikation mit der Service Layer)
│   ├── clients/
│   └── components/
│
├── server/
│   ├── service-layer/  (Routing, Validierung, Auth — Punkt 1.2)
│   ├── domain/          (Geschäftslogik — Punkt 1.3)
│   └── data-access/     (DB-/Cloud-Zugriffe, nur von domain/ aufgerufen)
│
└── legal/
    ├── impressum.html
    ├── datenschutz.html
    ├── cookie-policy.html
    └── agb.html
```

## 19. Benennungsregeln

- Verwendung von kebab-case: `index_header-button-left.css`, `login_google-login-button.js`, `shared_footer.css`.
- Nicht erlaubt: `HeaderButton.css`, `headerButton.css`, `styles.css`, `main.css`, `custom.css`, `new.css`.

## 20. Pflicht vor Implementierung

Vor jeder Implementierung müssen folgende Artefakte existieren:

1. HTML-Mock-up
2. CSS-Datei
3. JavaScript-Datei
4. i18n-Namespace mit allen verwendeten Keys inkl. deutschem Default-Text (3.2–3.4)
5. Accessibility-Check (Fokus, ARIA, Kontrast — Abschnitt 4)
6. Dokumentationseintrag
7. Architekturprüfung
8. Datenschutzprüfung (falls Daten verarbeitet werden)

Erst danach darf die Implementierung beginnen.

## 21. Verbote

- Keine Inline-Styles, kein Inline-JavaScript.
- Keine direkte Datenbank- oder Cloud-Anbindung aus der Client Layer.
- Keine Geschäftslogik außerhalb der Domain Layer (1.3).
- Keine rohen i18n-Keys im UI (z. B. `button_token_login` statt eines übersetzten Textes) — siehe 3.3.
- Keine Refresh-Tokens in `localStorage`/`sessionStorage` (siehe 11.2.1).
- Keine Emojis, keine extern geladenen Fonts, keine Gradienten ohne dokumentierte Ausnahme.
- Keine Tracking-Cookies, keine Tracking-Skripte.
- Keine eigenen Dialog-/Overlay-Grundgerüste ohne Fokus-Management und ARIA-Rollen (7.3).
- Keine zusätzlichen Dialog-, Toast- oder Overlay-Basisklassen neben den definierten Standard-Basisklassen.
- Keine allgemeinen CSS-Dateien wie `styles.css`, `main.css` oder `custom.css`.
- Keine allgemeinen JavaScript-Dateien wie `app.js`, `main.js` oder `helper.js`.
- Keine CSP-Ausnahmen (`'unsafe-inline'`) ohne dokumentierte Begründung (13.1).

# GUIDELINES_v2 — Addendum (Abschnitte 22–26)

> Ergänzt um Barrierefreiheitspflicht (BFSG/EAA), aktualisierte Security-Checkliste (OWASP Top 10:2025), EU Cyber Resilience Act, Kündigungsprozess sowie Daten- und Betriebsgrundlagen. Folgt demselben Muster wie 10.5/11.2.1: kein Rechtstext, sondern Trigger-Punkte mit Dokumentationspflicht.

## 22. Barrierefreiheits-Pflicht (BFSG/EAA)

### 22.1 Grundsatz
- Das Barrierefreiheitsstärkungsgesetz (BFSG) ist am 28. Juni 2025 in Kraft getreten und gilt für digitale B2C-Produkte und -Dienstleistungen, unabhängig von der Unternehmensgröße (Ausnahme: Kleinstunternehmen bei reinen Dienstleistungen — weniger als 10 Beschäftigte und ≤ 2 Mio. € Jahresumsatz).
- Maßgebliche Norm ist die EN 301 549, die aktuell auf WCAG 2.1 verweist; perspektivisch wird auf WCAG 2.2 umgestellt. Zielversion für neue Projekte ist von Anfang an WCAG 2.2 AA — Abschnitt 4.3 gilt unverändert, wird durch diesen Punkt rechtlich verschärft.

### 22.2 Barrierefreiheitserklärung (Pflichtdokument)
- Jedes Projekt mit B2C-Bezug erhält eine eigene `legal/barrierefreiheitserklaerung.html`, im Footer verlinkt (Ergänzung zu 9.2).
- Pflichtinhalt: aktueller Stand der Barrierefreiheit, bekannte Einschränkungen, Kontaktmöglichkeit für Feedback.
- i18n-Namespace entspricht dem Seitennamen (3.2), wie bei jedem anderen Footer-Dokument.

### 22.3 Dokumentationspflicht
- Vor jedem Public-Release wird ein Accessibility-Audit gegen WCAG 2.2 AA durchgeführt und das Ergebnis in `docs/decisions` festgehalten (analog 6.1, 10.5).

## 23. Sicherheits-Checkliste (OWASP Top 10:2025)

### 23.1 Grundsatz
- Referenzliste ist die OWASP Top 10:2025 (erste Aktualisierung seit 2021). Alle bisherigen Verweise auf die 2021er-Liste werden ersetzt.
- Jede Implementierung mit Außenwirkung (API-Endpunkt, Formular, Auth-Flow) wird vor Merge gegen die aktuelle Liste unter owasp.org/Top10/2025/ geprüft — zusätzliches Gate zu Punkt 20.

### 23.2 Bekannte strukturelle Verschiebungen (vor jedem Audit gegen die Quelle verifizieren)
- Broken Access Control bleibt Platz 1 und umfasst jetzt explizit BOLA/BFLA sowie SSRF-Fälle.
- Security Misconfiguration ist von Platz 5 auf Platz 2 gestiegen → Pflichtprüfung von Cloud-/Server-Defaults vor jedem Deployment.
- Software Supply Chain Failures ist eine neue Kategorie (erweitert die frühere "Vulnerable and Outdated Components" um Build- und Distributionspipeline) → siehe 23.3.
- Mishandling of Exceptional Conditions ist ebenfalls neu: Fail-Closed statt Fail-Open bei Fehlerzuständen, keine Stacktraces/internen Pfade in Client-Antworten (ergänzt 7.4).
- Die exakte Kategorienliste A01–A10 wird vor jedem Sicherheits-Audit live gegen owasp.org/Top10/2025/ abgeglichen, da Feinjustierungen möglich sind.

### 23.3 Software Supply Chain (SBOM)
- Für jedes Projekt wird eine Software Bill of Materials (SBOM) geführt und bei jedem Dependency-Update aktualisiert (Ablage: `docs/architecture/sbom.json`).
- Dependencies ausschließlich aus verifizierten Registries (npm, PyPI o. ä.); Lockfiles sind verpflichtend und werden versioniert.
- CI-Pipeline prüft bekannte CVEs in Dependencies vor jedem Merge.

## 24. EU Cyber Resilience Act (CRA) — Meldepflichten

### 24.1 Grundsatz
- Der CRA gilt für „Produkte mit digitalen Elementen", die auf dem EU-Markt angeboten werden — unabhängig vom Sitz des Herstellers. In Kraft seit 10. Dezember 2024, gestaffelte Fristen.
- Ab 11. September 2026: Meldepflicht für aktiv ausgenutzte Schwachstellen und schwerwiegende Sicherheitsvorfälle — Erstmeldung innerhalb 24 Stunden, Folgebericht innerhalb 72 Stunden, Abschlussbericht spätestens 14 Tage nach Fix.
- Ab 11. Dezember 2027: vollständige Anwendung aller CRA-Anforderungen (Secure-by-Design, Lebenszyklus-Schwachstellenmanagement, Transparenzpflichten).

### 24.2 Technische Vorbereitung (vor 11.09.2026 umzusetzen)
- `/.well-known/security.txt` nach RFC 9116 mit Kontaktadresse, ggf. PGP-Key, bevorzugter Sprache.
- Definierter Meldeweg an die zuständige nationale CSIRT (in Deutschland: BSI), dokumentiert in `docs/architecture/incident-response.md` (siehe 26.4).
- SBOM (23.3) ist Bestandteil der nach Anhang VII geforderten technischen Dokumentation.

### 24.3 Update-Zusage
- Für jedes Produkt wird ein Mindestzeitraum für Sicherheitsupdates festgelegt und öffentlich kommuniziert (Transparenzpflicht nach CRA).

## 25. Vertrags- und Kündigungsprozess

### 25.1 Kündigungsbutton (UI-Pflichtelement)
- Bei Abo- oder Vertragsmodellen erhält die Account-/Einstellungsseite einen eigenständigen Kündigungs-Button, maximal zwei Klicks von der Hauptnavigation entfernt.
- Technische Basis: eigene Komponente nach 15.1 (`<seitenname>_kuendigung-button.html/css/js`), erbt von `base-class-buttons` (7.1/7.2).
- Bestätigung erfolgt über einen Dialog nach 7.3 (`role="alertdialog"`), kein Redirect zu E-Mail/Telefon als einziger Weg.
- Hinweis: Eine Ausweitung der deutschen Kündigungsbutton-Pflicht (§ 312k BGB) auf weitere EU-Mitgliedstaaten zeichnet sich ab — Stichtag vor Implementierung verifizieren und in `docs/decisions` festhalten, da die Quellenlage hierzu aktuell uneinheitlich ist.

### 25.2 Datenlöschung nach Kündigung
- Mit erfolgreicher Kündigung wird der in 26.1 definierte Löschprozess ausgelöst, inklusive Lösch-/Anonymisierungsfrist.
- Der Nutzer erhält eine Bestätigung (i18n-Namespace der auslösenden Seite, 3.2) über Umfang und Zeitpunkt der Löschung.

## 26. Daten- und Betriebsgrundlagen

### 26.1 Datenklassifizierung & Löschkonzept
- Jede gespeicherte Datenkategorie wird klassifiziert: öffentlich / intern / personenbezogen / besonders sensibel (Art. 9 DSGVO).
- Pro Kategorie werden Aufbewahrungsfrist und automatisierter Löschprozess definiert und in `docs/architecture/datenklassifizierung.md` dokumentiert.

### 26.2 Verarbeitungsverzeichnis (Art. 30 DSGVO)
- Für jeden Dienst mit Personenbezug (eigene Datenbank, Google Login, Firebase, Analytics o. ä.) wird ein Eintrag geführt: Zweck, Datenkategorien, Empfänger, Löschfrist, Rechtsgrundlage.
- Pflicht vor Produktivschaltung jedes neuen Dienstes (ergänzt 20.8).

### 26.3 Auftragsverarbeitung & Drittlandtransfer
- Für jeden externen Dienstleister wird geprüft: Besteht ein AV-Vertrag? Sitz in EU/EWR, Land mit Angemessenheitsbeschluss, oder sind Standardvertragsklauseln (SCC) nötig?
- Ergebnis inkl. Prüfdatum wird in `docs/decisions` festgehalten (analog 10.5, 11.2.1).

### 26.4 Incident Response
- Ein zentrales Dokument (`docs/architecture/incident-response.md`) definiert Meldewege, Fristen und Verantwortlichkeiten für: Datenschutzvorfälle (Art. 33 DSGVO, 72h an Aufsichtsbehörde) und Sicherheitsvorfälle (CRA, 24h/72h an CSIRT, 24.2).
- Eskalationsstufen und Ansprechpartner sind projektweit identisch dokumentiert, nicht pro Komponente.

### 26.5 Secrets Management
- Keine Keys, Tokens oder Zugangsdaten im Code-Repository — auch nicht in `.env`-Dateien, die versehentlich eingecheckt werden könnten (`.gitignore`-Pflicht).
- Zentrale Secret-Verwaltung (z. B. Cloudflare Secrets, Vault) mit dokumentierter Rotationsfrequenz.

### 26.6 CI/CD & Umgebungstrennung
- Dev/Staging/Prod sind technisch und konfigurativ strikt getrennt (eigene Datenbanken, eigene Secrets).
- Dependency- und SAST-Scans (23.3) sind verpflichtende Merge-Gates, kein optionaler Schritt.
