# Everwild

Ruhiges, isometrisches Explorations-Puzzle für Mobile, gebaut mit Godot 4.

Alle Entscheidungen zu Spieldesign, Stil, Technik und Arbeitsteilung stehen in `docs/concept.md`. Vor jeder Arbeit lesen und bei neuen Entscheidungen aktualisieren.

Was noch zu bauen ist, steht in `docs/backlog.md`. Erledigtes dort löschen, Neues eintragen.

## Sprache

- **Englisch:** der gesamte Quellcode (GDScript, Shader, Python), Bezeichner, Kommentare, Datei- und Ordnernamen, Schlüssel und Werte in Datendateien, Kommandozeilen-Argumente und Programmausgaben. Das gilt für alles Neue.
- **Deutsch:** die Abstimmung mit Jan, `docs/concept.md`, `docs/backlog.md`, diese Datei und Commit-Nachrichten.

## Aufbau

- `src/logic/`: Spiellogik ohne Rendering. Muss headless laufen.
  - `GameState`: der zentrale Spielspeicher (Welt und Zelle der Figur, Fakten, Änderungen an Objekten je Welt, Gegenstände, Notizen). Reine Daten, speicherbar.
  - `World`: eine Welt aus ihrer Datei (heile Fassung), über die die Änderungen aus dem Spielspeicher gelegt werden.
  - `Session`: das laufende Spiel. Alles, was die Figur tut, läuft über `enter()` und `interact()`. Dort stehen auch alle Bedingungen und Folgen, die Regeln in Welt-Dateien benutzen dürfen.
  - `Solver`: spielt das ganze Spiel in allen Varianten durch und meldet Sackgassen.
  - `Mood`, `Iso`: Stimmungsregler und Umrechnung zwischen Zelle und Bildpunkt.
- `src/view/`: alles Sichtbare, Shader in `src/view/shaders/`. Die Hauptszene `scenes/game.tscn` baut ihre Knoten in `game.gd` per Code auf. Wind, Wasser und Schatten lesen ihre Richtung aus globalen Shader-Werten (`[shader_globals]` in `project.godot`), die `game.gd` aus der Stimmung setzt.
- `data/game.json`: Startwelt, Liste aller Welten und was beim Start eines neuen Spiels passiert.
- `data/worlds/`: Welten als JSON. Der Boden ist ein Zeichenraster (` ` Leere, `.` Gras, `=` Weg, `~` Wasser, `#` Brücke, `_` Boden eines Innenraums). `objects` beschreibt die heile Fassung, `broken` die Abweichungen der kaputten, `faults` die Fehler (jeder stellt bestimmte Stimmungsregler wieder her), `rules` was bei Interaktionen und beim Betreten von Zellen passiert.
- `data/notes.json`: alle Einträge des Notizbuchs mit Art, Welt und Verknüpfungen (immer in beide Richtungen).
- `data/texts/`: alle sichtbaren Texte je Sprache (`en.json`, `de.json`), mit denselben Schlüsseln in jeder Datei. Regeln nennen nur Schlüssel.
- `assets/`: Bilder und Musik, die das Spiel lädt (`objects/`, `worlds/`, `music/`).
- `tools/`: Python-Skripte für Bild- und Musikgenerierung, eigene Umgebung in `tools/.venv`. Die Stilvorgabe für alle Bild-Prompts steht in `tools/style.py`.
- `styletest/`: generierte Rohbilder und Testmusik, von Godot ignoriert.

## Befehle

Godot liegt unter `C:\godot\godot.exe` (4.7.2). Nach neuen Skripten mit `class_name` oder neuen Assets zuerst importieren.

```powershell
& "C:\godot\godot.exe" --headless --path . --import
& "C:\godot\godot.exe" --headless --path . --script tests/test_logic.gd
& "C:\godot\godot.exe" --path . -- --tap=11,9 --tap=16,9 --wait=3 --screenshot=C:/path/image.png
```

Der dritte Befehl startet das Spiel im Fenster, tippt nacheinander auf die Zellen, speichert ein Bildschirmfoto und gibt die Zelle der Figur, die offenen Fehler und den Stand der Musik aus (`src/view/test_helper.gd`). Ein Tipp auf ein Objekt mit Regel benutzt es. Mit `--intact` startet die Welt in der heilen Fassung. Im Spiel selbst wechselt vorläufig die Taste F zwischen heil und kaputt, die Taste N beginnt ein neues Spiel. Der Spielstand liegt in `user://save.json` (`%APPDATA%\Godot\app_userdata\Everwild`); Läufe mit Argumenten laden und speichern nur mit `--save=Pfad`. Headless kann Godot nicht rendern, für Bildschirmfotos braucht es das Fenster.

Der Test prüft auch die Lösbarkeit: Nach jeder Änderung an Welten oder Regeln laufen lassen.

Bild- und Musikgenerierung kostet Geld: nur auf ausdrückliche Anweisung von Jan und nur in der genannten Menge.

## Regeln

Die wichtigsten Regeln aus dem Konzept:

- Claude übernimmt die gesamte kreative Arbeit (Welten, Story, Grafik, Musik, Code, Tests). Jan entscheidet über Richtung und Geschmack und beurteilt, was Claude nicht kann: Spielgefühl, Touch und alles Hörbare.
- Jeder sichtbare Unterschied zwischen zwei Varianten einer Welt ist Absicht. Der Untergrund bleibt pixelgleich, Unterschiede entstehen nur über gezielt gesetzte Objekte, Shader und Verhalten.
- Kein Zustand darf unlösbar sein. Lösbarkeit wird automatisch geprüft.
- Spiellogik bleibt vom Rendering getrennt und deterministisch. Welten, Dialoge und Rätsel sind Daten.
