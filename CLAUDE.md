# Everwild

Ruhiges, isometrisches Explorations-Puzzle für Mobile, gebaut mit Godot 4. Sprache im Projekt und mit Jan: Deutsch.

Alle Entscheidungen zu Spieldesign, Stil, Technik und Arbeitsteilung stehen in `docs/konzept.md`. Vor jeder Arbeit lesen und bei neuen Entscheidungen aktualisieren.

## Aufbau

- `src/logik/`: Spiellogik ohne Rendering (`Welt`, `Iso`, `Stimmung`). Muss headless laufen.
- `src/ansicht/`: alles Sichtbare, Shader in `src/ansicht/shader/`. Wind, Wasser und Schatten lesen ihre Richtung aus globalen Shader-Werten (`[shader_globals]` in `project.godot`), die `spiel.gd` aus der Stimmung setzt. Die Hauptszene `scenes/spiel.tscn` baut ihre Knoten in `spiel.gd` per Code auf.
- `data/welten/`: Welten als JSON. Der Boden ist ein Zeichenraster (` ` Leere, `.` Gras, `=` Weg, `~` Wasser, `#` Brücke).
- `tools/`: Python-Skripte für Bild- und Musikgenerierung, eigene Umgebung in `tools/.venv`. Die Stilvorgabe für alle Bild-Prompts steht in `tools/stil.py`.
- `stiltest/`: generierte Testbilder und -musik, von Godot ignoriert.

## Befehle

Godot liegt unter `C:\godot\godot.exe` (4.7.2). Nach neuen Skripten mit `class_name` oder neuen Assets zuerst importieren.

```powershell
& "C:\godot\godot.exe" --headless --path . --import
& "C:\godot\godot.exe" --headless --path . --script tests/test_logik.gd
& "C:\godot\godot.exe" --path . -- --tippe=11,9 --tippe=16,9 --warte=3 --foto=C:/pfad/bild.png
```

Der dritte Befehl startet das Spiel im Fenster, tippt nacheinander auf die Zellen, speichert ein Bildschirmfoto und gibt die Zelle der Figur und den Stand der Musik aus (`src/ansicht/testhilfe.gd`). Mit `--falsch` läuft es in der falschen Stimmung der Welt. Im Spiel selbst wechselt vorläufig die Taste F zwischen heil und falsch. Headless kann Godot nicht rendern, für Bildschirmfotos braucht es das Fenster.

Bild- und Musikgenerierung kostet Geld: nur auf ausdrückliche Anweisung von Jan und nur in der genannten Menge.

## Regeln

Die wichtigsten Regeln aus dem Konzept:

- Claude übernimmt die gesamte kreative Arbeit (Welten, Story, Grafik, Musik, Code, Tests). Jan entscheidet über Richtung und Geschmack und beurteilt, was Claude nicht kann: Spielgefühl, Touch und alles Hörbare.
- Jeder sichtbare Unterschied zwischen zwei Varianten einer Welt ist Absicht. Der Untergrund bleibt pixelgleich, Unterschiede entstehen nur über gezielt gesetzte Objekte, Shader und Verhalten.
- Kein Zustand darf unlösbar sein. Lösbarkeit wird automatisch geprüft.
- Spiellogik bleibt vom Rendering getrennt und deterministisch. Welten, Dialoge und Rätsel sind Daten.
