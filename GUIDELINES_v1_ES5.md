# Universal Web Guidelines
*Extrahiert und konsolidiert aus: Guide Lines-UI-.txt · Guide Lines Premium UI-.txt · GUIDELINE_NEW_STYLING · GUIDELINE_NEW_ARCHITECTURE*
*Stand: Juni 2026 — aktualisiert um DATENSCHUTZ / Fonts lokal*

---

## LAYOUT

### Grid & Container
- **12-column grid.** Content in 8 von 12 Spalten auf Desktop.
- **Container:** `max-width: 1280px`, `margin-inline: auto`, `padding-inline: 32px`
- Spaltenaufteilung: Volle Breite = 12/12 · Content + Sidebar = 8+4 · Zwei gleich = 6+6

### Spacing — 8pt Grid
- Alle Abstände durch **4 oder 8 teilbar** — keine Ausnahmen (15px, 22px, 7px → verboten)
- Skala: 4 · 8 · 16 · 24 · 32 · 48 · 64 · 96 · 128 px

### Proximity-Prinzip
- **16px** = Elemente innerhalb einer Gruppe (Label über Input, Icon neben Text)
- **32px** = zwischen verschiedenen Gruppen / Komponenten
- **64px+** = zwischen Sections

### Seitenstruktur
- Standard: `app-shell → main.page → page-header`
- Navbar: 64px Höhe, sticky, `border-bottom: 1px solid neutral-200`, `bg: neutral-0`
- Sichtbarkeit nur via CSS-Klasse (`.is-hidden`), niemals `el.style.display = 'none'`

### Basisklassen für wiederkehrende Komponenten
- Navbars, Dialoge, Modals, Toasts, Cards, Formulare — immer als **Basisklasse** implementieren
- **Dialoge und Toasts haben IMMER eine Basisklasse** — direkte Nutzung von `alert()`, `confirm()`, `window.prompt()` oder eigenständige Dialog-Implementierungen ohne Basisklasse sind verboten
- Basisklassen definieren Struktur, Spacing und States — Seiten-spezifische Varianten **erweitern** sie (z.B. `.dialog--wide`, `.navbar--transparent`)
- Keine Komponente mehrfach neu implementieren — erst prüfen ob eine Basisklasse existiert oder erweitert werden kann
- Basisklassen leben in einer eigenen CSS-Datei (z.B. `components.css`) — niemals in seitenspezifischem CSS

### Scroll-Isolation (ScrollViews)
- **Seitenleisten und Content-Bereiche dürfen sich beim Scrollen nicht gegenseitig beeinflussen**
- Sidebar und Content müssen immer in **separaten ScrollViews** untergebracht werden:
  - Eltern-Container: `height: calc(100vh - var(--nav-height))` + `overflow: hidden`
  - Sidebar: `height: 100%` + `overflow-y: auto`
  - Content: `height: 100%` + `overflow-y: auto`
- `position: sticky` auf Sidebar **nur** wenn der Eltern-Container selbst kein Overflow hat

### Responsive Breakpoints (alle durch 8 teilbar)
480px · 768px · 1024px · 1280px · 1536px

### Ausrichtung
- Body-Copy **linksbündig** — Zentrierung nur für kurze Hero-Headlines
- Eine primäre Aktion pro Section — nie mit sich selbst konkurrieren

### Touch & Hover
- Hover-States nur in `@media (hover: hover) and (pointer: fine)` (verhindert "sticky hover" auf Touch)
- Touch Targets: min. **44px** Höhe für alle Buttons und Links

---

## ARCHITEKTUR

### No-Build-Strategie
*Diese Rules dürfen verletzt/angepasst werden, wenn technisch zwingende Gründe vorliegen (z.B. API-Integration). Abweichungen nur wenn: 1. technisch zwingend, 2. lokal begrenzt, 3. dokumentiert in PD.txt, 4. keine globale Architekturdrift entsteht.*

- Kein Webpack, kein Vite, kein Babel — direkte Browser-Ausführung
- **ES5-Syntax:** `var`, `function(){}`, String-Konkatenation — kein `let/const`, keine Arrow Functions, kein Template Literals, kein Destructuring, kein Spread
- **Kein `import/export`** — IIFE-Pattern für alle Module:
  ```js
  var MyModule = (function() {
    'use strict';
    var _private = null;
    function publicMethod() {}
    return { publicMethod: publicMethod };
  }());
  ```
- HTML, CSS und JS immer in **getrennten Dateien**

### Schichten-Architektur
```
UI-Layer (page-specific JS)
    ↓ AppService.method(params, callback)
AppService (app-service.js)
    ↓ delegiert an aktiven Adapter
LocalStorageAdapter / RemoteAdapter
    ↓ einziger direkter Zugriff
Store / ProfileStore
```
- Consumer-Code greift **niemals** direkt auf `Store.*` oder `localStorage` zu — immer `AppService.*`
- Adapter-Swap = **eine Zeile** in `app-config.js`

### Async-Konvention
- Alle Callbacks folgen Node.js-Konvention: `function(err, result)`
- Fehler nie verschlucken — Adapter liefert immer `callback(err, null)` bei Fehler

### Asset-Versioning
- `APP_VERSION` bei **jeder** inhaltlichen Änderung an .js oder .css erhöhen (Format: `YYYY-MM-DD-{n}`)
- Assets werden über `app-config.js` injiziert — niemals hardcoded `?v=` in HTML
- CSS-Ladereihenfolge: `fonts → tokens → base → components → navbar → [page-specific]`
- Script-Ladereihenfolge: `app-config.js` immer zuerst

### Externe Abhängigkeiten
- Externe Ressourcen auf ein **absolutes Minimum** reduzieren
- Kritische Assets (Fonts, Icons) **immer lokal hosten** — nie über externe CDNs laden
- Ausnahme: notwendige SDKs (Firebase, Stripe etc.) — dokumentieren warum extern

### Locale — Sprache / Währung / Zeitzone
Prioritäts-Hierarchie (niedrig → hoch, letzter Wert gewinnt):
1. **Browser-Erkennung** beim ersten Öffnen: `navigator.language`, `Intl.DateTimeFormat().resolvedOptions().timeZone`
2. **localStorage** — falls der User die Einstellung in der App manuell gesetzt hat
3. **Nutzerprofil aus der DB** — nach dem Einloggen (überschreibt localStorage)

- Locale-Objekt: `{ language: 'de', currency: 'EUR', timezone: 'Europe/Berlin' }`
- `localStorage` nur beschreiben wenn der User aktiv eine Einstellung setzt — nie beim bloßen Browser-Detect
- Währungs-Formatierung immer über `Intl.NumberFormat` — niemals manuell

### Datenschema
- Flache Arrays als Collections — max. 1 Ebene Verschachtelung
- Codes statt Klartexte: `'de'` statt `'Deutsch'`
- Bestehende Schemas sind **unveränderlich** — nur additive Felder erlaubt

### Sicherheit
- `_esc(str)` bei jedem User-Daten-Output in `innerHTML` — keine Ausnahme (XSS-Schutz)
- `window.alert()` / `window.confirm()` / `window.prompt()` → immer eigene Modal/Toast-Lösung

### Mockup-Workflow
- **Erst Mockup erstellen, vom User freigeben lassen, dann implementieren**
- Kein UI-Code ohne vorheriges Mockup

---

## DATENSCHUTZ & PRIVACY

*Gilt für alle Projekte ohne Ausnahme. Ziel: Kein Cookie-Banner nötig, keine Abmahnung durch Datenschutzbehörden.*

### Fonts — immer lokal hosten

**PFLICHT: Keine externen Font-Dienste.**

```
VERBOTEN:
  <link href="https://fonts.googleapis.com/...">
  @import url('https://fonts.googleapis.com/...')
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com">

KORREKT:
  1. WOFF2-Dateien herunterladen → /fonts/ Verzeichnis
  2. css/fonts.css mit @font-face Deklarationen
  3. <link rel="stylesheet" href="/css/fonts.css"> in jeden <head>
```

```css
/* css/fonts.css */
@font-face {
  font-family: 'Figtree';
  font-style: normal;
  font-weight: 100 900;
  font-display: swap;
  src: url('/fonts/figtree-latin-ext.woff2') format('woff2');
  unicode-range: U+0100-02BA, U+02BD-02C5, U+02C7-02CC, U+02CE-02D7, U+02DD-02FF,
                 U+0304, U+0308, U+0329, U+1D00-1DBF, U+1E00-1E9F, U+1EF2-1EFF,
                 U+2020, U+20A0-20AB, U+20AD-20C0, U+2113, U+2C60-2C7F, U+A720-A7FF;
}
@font-face {
  font-family: 'Figtree';
  font-style: normal;
  font-weight: 100 900;
  font-display: swap;
  src: url('/fonts/figtree-latin.woff2') format('woff2');
  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA,
                 U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122,
                 U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;
}
```

**Warum:** Google Fonts überträgt die IP-Adresse des Besuchers an Google-Server (USA) — unzulässige Datenübermittlung nach DSGVO (EuGH + LG München 2022). Abmahnfähig ohne Einwilligung.

**Figtree WOFF2 herunterladen (PowerShell):**
```powershell
$ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124.0.0.0 Safari/537.36'
$css = Invoke-WebRequest 'https://fonts.googleapis.com/css2?family=Figtree:wght@400;600&display=swap' -UserAgent $ua -UseBasicParsing
# WOFF2-URLs aus $css.Content extrahieren und mit Invoke-WebRequest -OutFile herunterladen
```

### Cookies — nur First-Party, kein Banner nötig

| Typ | Erlaubt ohne Banner | Beispiele |
|-----|--------------------|-|
| Session-Auth-Cookie | Ja | HttpOnly, SameSite=Strict |
| localStorage | Ja | Spracheinstellung, Theme |
| Third-Party-Analytics | Nein | Google Analytics, Hotjar |
| Marketing/Retargeting | Nein | Meta Pixel, GTM |

Wenn Analytics nötig: nur DSGVO-konforme Lösungen ohne Fingerprinting (Plausible, Fathom, self-hosted Matomo mit IP-Anonymisierung).

### Tracking & externe Requests

- Kein Tracking-Pixel ohne Einwilligung
- Keine CDN-Ressourcen für Fonts und Icons — alles lokal
- Social-Share-Buttons: nur einfache `href`-Links, keine eingebetteten Widgets
- Vor jeder externen Ressource: *"Überträgt das eine IP-Adresse an Dritte?"* — wenn ja, lokal ersetzen

### DSGVO-Checkliste — bei jedem Projekt prüfen

- [ ] `grep -r "fonts.googleapis\|fonts.gstatic" --include="*.html" --include="*.css" .` → 0 Treffer
- [ ] Alle Fonts als WOFF2 in `/fonts/` vorhanden
- [ ] `css/fonts.css` mit lokalen `@font-face` Deklarationen erstellt
- [ ] Kein Google Analytics / GTM ohne Einwilligungs-Banner
- [ ] Session-Cookies: `HttpOnly` + `SameSite=Strict`
- [ ] Datenschutzerklärung verlinkt (bei öffentlicher App)
- [ ] Externe SDKs auf Notwendigkeit geprüft und in PROJECT_GUIDELINES.md dokumentiert

---

## SIMPLE

### Tokens — keine hardcoded Werte
- Alle Farben, Schriftgrößen, Abstände ausschließlich als **CSS Custom Properties** (`var(--...)`)
- Hex-Werte und px-Werte nur in `tokens.css` innerhalb `:root` — nirgends sonst
- Kein Inline-CSS im HTML (`style="..."`) — Ausnahme: dynamische JS-Laufzeitwerte

### Farbsystem
- **Keine Gradients** — nur flache, einfarbige Fills
- Tiefe entsteht durch Spacing und Kontrast, nicht durch Texturen oder Verläufe
- Nur **eine Hue** — alle Farben als Tints/Shades aus einer Basis

### Typografie
- Max. **4 Schriftgrößen** (Display 48 · Heading 24 · Body 16 · Caption 12)
- Max. **2 Gewichte** (400 Regular · 600 Semibold) — kein drittes Gewicht, auch nicht per `opacity` simuliert
- Keine Emojis in UI-Text, Labels, Buttons, Fehlermeldungen, Tooltips
  - Ausnahme: dekorative Brand-Elemente in Hero-Sections → im HTML mit `<!-- emoji-exception: approved -->` markieren

### Icons
- Eine einzige Icon-Library — keine gemischten Styles
- Größen: **16px oder 24px** (beide durch 8 teilbar)
- Primäre Aktionen: Icon immer **mit Textlabel** kombiniert

### Motion
- Kein Bounce, kein Spring, kein Elastic
- Keine Layout-Animationen (`width`, `height`, `top`) — nur `transform` und `opacity`
- Smooth Scroll nur unter `prefers-reduced-motion: no-preference`

### Copywriting
- **CTAs: max. 3 Wörter**, Verb-First (Anmelden · Speichern · Weiter · Fertig)
- Navigation: 1 Wort wo möglich (Preise · Docs · Blog)
- Keine Füllwörter: kein "Bitte", "Einfach", "Hier klicken"
- Kein Passiv: "Gespeichert" statt "Wurde erfolgreich gespeichert"
- Fehlermeldungen: Was passiert ist + was zu tun ist — nicht was intern fehlschlug

### Code-Struktur
- Niemals Inline-CSS oder Inline-JS (`style="..."`, `onclick="..."`)
- HTML, CSS und JavaScript immer in getrennten Dateien
- Standard-Browser-Dialoge (`alert`, `confirm`, `prompt`) → immer eigene Custom-Dialoge
- Alle wiederkehrenden UI-Elemente als Basisklasse (DRY-Prinzip)

---

## PREMIUM

### Philosophie
> Premium-Interfaces sind durch Zurückhaltung definiert. Jedes Element verdient seinen Platz. Das Ziel ist nicht zu beeindrucken — sondern dass der User sich sofort handlungsfähig fühlt. (Stripe · Linear · Vercel · Apple)

### Farbsystem — Single-Hue (Eric D. Kennedy)
- Basis: `#060f1c` (Navy, HSL 216, 65%, 7%)
- Tints (heller) reduzieren Sättigung · Shades (dunkler) halten oder erhöhen sie leicht

**Brand-Skala:**

| Token | Hex | HSL | Verwendung |
|-------|-----|-----|-----------|
| color-50 | #f3f5fb | 216, 30%, 97% | Page backgrounds |
| color-100 | #e5eaf5 | 216, 35%, 92% | Surface, Cards |
| color-200 | #c8d3ec | 216, 42%, 83% | Borders, Dividers |
| color-300 | #99b0db | 216, 48%, 68% | Disabled states |
| color-400 | #5b87cc | 216, 54%, 52% | Interactive accent |
| color-500 | #2a5fa8 | 216, 60%, 38% | Hover state |
| color-600 | #1a3e73 | 216, 63%, 26% | Active state |
| color-700 | #102449 | 216, 64%, 17% | Dark UI elements |
| color-800 | #0a1830 | 216, 65%, 11% | Headers, Nav |
| color-900 | #060f1c | 216, 65%, 7% | Base / near-black |

**Neutral-Skala:**

| Token | Hex | Verwendung |
|-------|-----|-----------|
| neutral-0 | #ffffff | Pure white |
| neutral-50 | #f8f9fa | Default background |
| neutral-100 | #f1f3f5 | Subtle surface |
| neutral-200 | #e9ecef | Borders |
| neutral-300 | #dee2e6 | Dividers |
| neutral-500 | #adb5bd | Muted text |
| neutral-700 | #495057 | Body text |
| neutral-900 | #212529 | Heading text |

**60-30-10 Verteilung:**
- 60 % Neutral → Seitenhintergründe, Card-Surfaces, White-Space
- 30 % Komplementär → Text, Navigation, Footer, Sidebar
- 10 % Accent → CTAs, Links, Focus-Ringe, aktive Indikatoren

### Typografie
- Font: **Figtree** (400 Regular + 600 Semibold) — kein zweiter Font
- **Lokal gehostet** als WOFF2 in `/fonts/` — niemals über Google Fonts CDN
- Headings niemals grau — immer `neutral-900` oder `color-900`
- `neutral-500` (Muted) nur für wirklich sekundäre Inhalte

### Kontrast & Barrierefreiheit
- Kontrast >= 4.5:1 für Fließtext (WCAG AA)
- Focus-Ring: immer sichtbar, niemals unterdrückt — `outline: none` nur mit `box-shadow`-Ersatz
- `:focus-visible` verwenden (mit Fallback)

### Interaktive Zustände — alle 5 Pflicht
Jedes interaktive Element braucht: **default · hover · active · focus · disabled**
- Hover: eine Stufe nach unten auf der Farbskala (color-400 → color-500)
- Disabled: `opacity: 0.4; cursor: not-allowed`

### Transitions
- **120ms ease** — Hover-States, Icon-Wechsel
- **200ms ease** — Panels, Drawers, Modals einblenden

### Schatten & Tiefe
- Kein starker Drop-Shadow — subtil: `0 1px 3px rgba(6,15,28,0.08)`
- Cards: `1px solid neutral-200` liest sich sauberer als ein Shadow auf Weiß
- Tiefe kommt von **Spacing-Hierarchie und Kontrast** — nicht von Schatten, Gradients oder Texturen

### CSS Tokens — Vollständige Vorlage
```css
/* tokens.css */
:root {
  /* Brand */
  --color-50:  #f3f5fb; --color-100: #e5eaf5; --color-200: #c8d3ec;
  --color-300: #99b0db; --color-400: #5b87cc; --color-500: #2a5fa8;
  --color-600: #1a3e73; --color-700: #102449; --color-800: #0a1830;
  --color-900: #060f1c;

  /* Neutral */
  --neutral-0:   #ffffff; --neutral-50:  #f8f9fa; --neutral-100: #f1f3f5;
  --neutral-200: #e9ecef; --neutral-300: #dee2e6; --neutral-400: #ced4da;
  --neutral-500: #adb5bd; --neutral-600: #868e96; --neutral-700: #495057;
  --neutral-800: #343a40; --neutral-900: #212529;

  /* Typography */
  --font-family: 'Figtree', -apple-system, BlinkMacSystemFont, sans-serif;
  --text-display: 48px; --text-heading: 24px;
  --text-body: 16px;    --text-caption: 12px;

  /* Spacing */
  --space-1: 4px;  --space-2: 8px;  --space-3: 16px; --space-4: 24px;
  --space-5: 32px; --space-6: 48px; --space-7: 64px; --space-8: 96px;
  --space-9: 128px;

  /* Transitions */
  --transition-fast: 120ms ease;
  --transition-base: 200ms ease;

  /* Radius */
  --radius-sm: 4px; --radius-md: 8px; --radius-lg: 16px;

  /* Shadow */
  --shadow-sm: 0 1px 3px rgba(6,15,28,0.08);
  --shadow-md: 0 4px 12px rgba(6,15,28,0.12);
}
```

---

## QUICK REFERENCE — DO / DON'T

| Do | Don't |
|----|-------|
| Fonts als WOFF2 lokal in /fonts/ hosten | Google Fonts CDN in HTML/CSS einbinden |
| `<link rel="stylesheet" href="/css/fonts.css">` | `<link href="https://fonts.googleapis.com/...">` |
| Figtree 400 und 600 verwenden | 3 oder mehr Fontgewichte |
| Abstände als Vielfaches von 4 oder 8 | 15px, 22px, 7px verwenden |
| Flache einfarbige Fills | Gradients oder Farbverläufe |
| Custom-Dialoge (Modal, Toast) | `alert()`, `confirm()`, `prompt()` |
| CSS Custom Properties (`var(--...)`) | Hardcoded Hex- oder px-Werte |
| Basisklassen für wiederkehrende Elemente | Komponenten mehrfach neu implementieren |
| Erst Mockup, dann Code | UI ohne Mockup direkt implementieren |
| First-Party-Cookies (HttpOnly, SameSite=Strict) | Third-Party-Tracking-Cookies ohne Banner |
| Icon + Textlabel auf primären Aktionen | Icon ohne Label auf primären Aktionen |
| 4.5:1 Kontrast (WCAG AA) | Graue Headlines unter Kontrast-Schwelle |
| Inline-Events via addEventListener | `onclick="..."` im HTML |
