# Everwild

Ruhiges, isometrisches Explorations-Puzzle für Mobile, gebaut mit Godot 4. Sprache im Projekt und mit Jan: Deutsch.

Alle Entscheidungen zu Spieldesign, Stil, Technik und Arbeitsteilung stehen in `docs/konzept.md`. Vor jeder Arbeit lesen und bei neuen Entscheidungen aktualisieren.

Die wichtigsten Regeln daraus:

- Claude übernimmt die gesamte kreative Arbeit (Welten, Story, Grafik, Musik, Code, Tests). Jan entscheidet über Richtung und Geschmack und beurteilt, was Claude nicht kann: Spielgefühl, Touch und alles Hörbare.
- Jeder sichtbare Unterschied zwischen zwei Varianten einer Welt ist Absicht. Der Untergrund bleibt pixelgleich, Unterschiede entstehen nur über gezielt gesetzte Objekte, Shader und Verhalten.
- Kein Zustand darf unlösbar sein. Lösbarkeit wird automatisch geprüft.
- Spiellogik bleibt vom Rendering getrennt und deterministisch. Welten, Dialoge und Rätsel sind Daten.
