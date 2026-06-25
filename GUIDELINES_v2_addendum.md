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
