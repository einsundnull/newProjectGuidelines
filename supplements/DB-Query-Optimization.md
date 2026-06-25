# DB Query Optimization — Richtlinien für Phoenix Code HTML

**Konzept:** Scoped Queries / Principle of Least Data Access  
**Anti-Pattern:** Unbounded Query (Full Collection Scan)  
**Gültig für:** Firestore (firebase), alle Collection-Abfragen

---

## Das Grundprinzip

> **Lies niemals mehr Dokumente als du brauchst.**  
> Jedes `.get()` auf eine Collection ohne `.where()` ist ein Full Collection Scan —  
> er liest ALLE Dokumente aller Nutzer. Das verbraucht Quota proportional zur  
> Gesamtzahl der Dokumente in der DB, nicht zur Anzahl der relevanten Dokumente.

---

## Checkliste vor jeder Firestore-Abfrage

Vor jeder neuen DB-Abfrage diese Fragen beantworten:

1. **Ist die Query auf den aktuellen User beschränkt?**  
   → Jede Abfrage muss `.where('teacherId', '==', uid)` oder `.where('studentId', '==', uid)` enthalten, sofern die Collection nutzerspezifische Daten enthält.

2. **Wird die gesamte Collection benötigt, oder nur ein Teil davon?**  
   → `collection.get()` ohne Filter = **verboten** für nutzerspezifische Collections.  
   → Erlaubt nur für echte globale Collections (z. B. `config`, `appVersion`).

3. **Wird die Abfrage bei jedem Page-Load ausgeführt?**  
   → Wenn ja: Ergebnis in den In-Memory-Cache (`_cache`) schreiben.  
   → Nie dieselbe Abfrage zweimal ausführen ohne Cache-Invalidierung.

4. **Wird die Abfrage durch eine Nutzeraktion ausgelöst (on-demand)?**  
   → Kein Problem — aber Ergebnis für die Session zwischenspeichern.

5. **Gibt es ein Composite-Index-Risiko?**  
   → `.where(A).where(B)` braucht einen Firestore Composite Index.  
   → Singlefeld-Abfragen (`.where(A)`) brauchen keinen extra Index.

---

## Verbotene Muster

```js
// ❌ VERBOTEN — liest ALLE Slots aller Lehrer und Schüler
db.collection('slots').get()

// ❌ VERBOTEN — liest ALLE Escrows des gesamten Systems
db.collection('escrows').get()

// ❌ VERBOTEN — liest ALLE Selections aller Nutzer
db.collection('selections').get()

// ❌ VERBOTEN — liest ALLE Recurring-Regeln aller Lehrer
db.collection('recurring').get()

// ❌ VERBOTEN — liest ALLE Profile aller Nutzer (wenn nutzerspezifisch)
db.collection('profiles').get()
```

---

## Erlaubte Muster

```js
// ✅ RICHTIG — Slots nur für diesen Lehrer
db.collection('slots').where('teacherId', '==', uid).get()

// ✅ RICHTIG — Escrows nur für diesen Lehrer
db.collection('escrows').where('teacherId', '==', uid).get()

// ✅ RICHTIG — Selections nur für diesen Lehrer
db.collection('selections').where('teacherId', '==', uid).get()

// ✅ RICHTIG — Recurring nur für diesen Lehrer
db.collection('recurring').where('teacherId', '==', uid).get()

// ✅ RICHTIG — Einzelnes Dokument lesen
db.collection('wallets').doc(uid).get()

// ✅ RICHTIG — Gefiltert nach UID + Status (kein Composite-Index nötig, da Single-Field)
db.collection('slots').where('studentId', '==', studentUid).get()
// → Client-seitig nach status filtern

// ✅ RICHTIG — On-demand Query, Ergebnis gecacht
if (_cache.studentConflicts[uid]) { return callback(null, _cache.studentConflicts[uid]); }
db.collection('slots').where('studentId', '==', uid).get().then(...)
```

---

## Wann darf `.get()` ohne Filter verwendet werden?

Nur wenn **alle drei** Bedingungen erfüllt sind:

| Bedingung | Beispiel |
|---|---|
| Die Collection enthält globale, nicht-nutzerspezifische Daten | `appConfig`, `languages` |
| Die Collection ist dauerhaft klein (< 100 Docs) | `roles`, `featureFlags` |
| Das Ergebnis wird für die gesamte Session gecacht | `_cache.config` |

---

## Preload-Regeln (`adapter-firestore.js` → `preload()`)

Der Preload läuft **einmal pro Page-Load**. Jede dort gelesene Collection multipliziert die Reads mit der Anzahl aller Dokumente in dieser Collection.

**Pflichtfilter im Preload:**

| Collection | Pflichtfilter |
|---|---|
| `slots` | `.where('teacherId', '==', uid)` |
| `recurring` | `.where('teacherId', '==', uid)` |
| `selections` | `.where('teacherId', '==', uid)` |
| `escrows` | `.where('teacherId', '==', uid)` |
| `transactions` | `.where('uid', '==', uid)` ✓ bereits korrekt |
| `favorites` | `.where('studentId', '==', uid)` ✓ bereits korrekt |
| `wallets` | `.doc(uid).get()` ✓ bereits korrekt |
| `users` | Ausnahme — wird für Namens-Lookups benötigt; bleibt breit |

---

## Cross-User-Daten (z. B. Ghost Panels)

Wenn Daten eines **anderen Nutzers** benötigt werden (z. B. Slots eines Schülers bei einem anderen Lehrer), gilt:

- ❌ Nicht im Preload laden (zu teuer, zu breit)
- ✅ On-demand laden, wenn der User die entsprechende Aktion auslöst
- ✅ Ergebnis für die Session im Memory zwischenspeichern
- ✅ Spezifische Funktion dafür schreiben (z. B. `getBookedSlotsByStudent`)

```js
// ✅ RICHTIG — On-demand, targeted, nur was gebraucht wird
function getBookedSlotsByStudent(studentUid, callback) {
  db.collection('slots')
    .where('studentId', '==', studentUid)  // Single-field, kein Index nötig
    .get()
    .then(function(snap) {
      var slots = [];
      snap.forEach(function(doc) {
        var d = doc.data();
        if (d.status === 'booked') slots.push(d);  // Client-seitig filtern
      });
      callback(null, slots);
    });
}
```

---

## Kostenvergleich: Beispielrechnung

Annahme: 50 Lehrer, je 100 Slots, 200 Escrows gesamt, 150 Selections gesamt.

| Query | Vor der Optimierung | Nach der Optimierung |
|---|---|---|
| `slots.get()` | 5.000 Reads | 100 Reads |
| `escrows.get()` | 200 Reads | 4 Reads |
| `selections.get()` | 150 Reads | 3 Reads |
| `recurring.get()` | 50 Reads | 1 Read |
| **Gesamt pro Page-Load** | **~5.400 Reads** | **~108 Reads** |
| **Free Quota (50k/Tag)** | erschöpft nach ~9 Loads | reicht für ~460 Loads |

---

## myLangSite als Referenz

myLangSite hat dieses Problem strukturell gelöst durch **Subcollections**:

```
teachers/{uid}/availability/   ← nur für diesen Lehrer lesbar
teachers/{uid}/booked/         ← nur für diesen Lehrer lesbar
students/{uid}/lessons/        ← nur für diesen Schüler lesbar
```

Subcollections erzwingen automatisch User-Scoping — ein Full Collection Scan
ist strukturell unmöglich. Phoenix Code HTML verwendet flache Collections, weshalb
die Filter-Disziplin beim Entwickler liegt.

---

## Zusammenfassung

| Regel | Beschreibung |
|---|---|
| **Scope Every Query** | Jede Collection-Abfrage braucht einen UID-Filter |
| **Preload = Minimum** | Im Preload nur lesen, was auf dem ersten Screen gebraucht wird |
| **On-Demand for Cross-User** | Fremddaten erst laden, wenn der User sie aktiv anfordert |
| **Cache Aggressively** | Jede Firestore-Antwort einmal lesen, dann im Memory halten |
| **No Unbounded Reads** | `.collection().get()` ohne `.where()` = Code-Review-Blocker |
