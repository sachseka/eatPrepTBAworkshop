# Kleine Partial-Credit-Demonstration

Alle Antworten, Personenkennungen und Metadaten in den `demo-*`-Dateien sind
synthetisch. Es handelt sich nicht um Originalexports aus IQB-Studio oder einer
StarS-Erhebung. Die Dateien sind unabhängig von der größeren Mini-Studie.

Die Aufgabe und die Bewertungsregeln folgen Abschnitt 2.3 (Numerische Kurzantwort)
von Eva Crone: [Anleitung zur Anlage der Partial-Credit-Kodierung](https://iqb-research.github.io/IQB-Methods/docs/studio/partial_credit.html#numerische-kurzantwort),
27.08.2026. Die zugehörigen Original-Screenshots sind unverändert übernommen.

| Variable | Aufgabe | Richtiger Wert | Punkte |
|---|---|---|---|
| `01a` | 10 + 11 | 21 | 0 oder 1 |
| `01b` | 11 + 101 | 112 | 0 oder 1 |
| `01c` | 101 + 1001 | 1102 | 0 oder 1 |
| `01` | Abgeleitet: Summe der Basispunkte | 3 / 2 / höchstens 1 | 2 / 1 / 0 |

Bei Variable `01` gilt: Code 1 hat Score 2, Code 2 hat Score 1, Code 0 hat Score 0.
Nur `01` ist mit dem synthetischen Item `RECHNEN_01` verknüpft.

Das rekonstruierte Kodierschema beschränkt sich auf die für diese Antworten
benötigten Regeln. Zusätzliche Schreibweisen von Tausenderzahlen, die das Tutorial
ebenfalls behandelt, sind nicht nachgebildet.

- `demo-pc-units.rds`: eine Unit mit vier Variablen im Kodierschema.
- `demo-pc-responses.csv`: vier Personen mit je drei Rohantworten.
- `demo-stored-codes.csv`: nachgebildeter Export mit bereits gespeicherten Codes.
  Zeigt den Importweg, der z. B. für StarS-Daten relevant ist.
- `R/02_daten_verstehen.R`: lineares, lokal ausführbares Lehrskript.
- `scripts/generate_demonstration_data.R`: erzeugt diese Dateien reproduzierbar.
- `scripts/validate_demonstration_data.R`: prüft die erwarteten Ergebnisse.

Es gibt kein vollständiges Studiendesign, keine fehlenden Antworten und keine
manuellen Kodierungen. Diese Schritte zeigt die separate größere Mini-Studie.
