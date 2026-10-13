# Everwild

Ruhiges, isometrisches Explorations-Puzzle für Mobile, gebaut mit Godot 4.

Alle Entscheidungen zu Spieldesign, Stil, Technik und Arbeitsteilung stehen in `docs/concept.md`. Vor jeder Arbeit lesen und bei neuen Entscheidungen aktualisieren.

Was noch zu bauen ist, steht in `docs/backlog.md`. Erledigtes dort löschen, Neues eintragen.

Der Spielinhalt steht je Kapitel in `docs/chapters/` (bisher `valley.md`): Geschichte, Orte, Figuren, Rätsel und Zusammenhänge, als Text und als feste Blöcke. Wer Welten, Regeln oder Texte eines Kapitels ändert, ändert auch seine Datei.

## Sprache

- **Englisch:** der gesamte Quellcode (GDScript, Shader, Python), Bezeichner, Kommentare, Datei- und Ordnernamen, Schlüssel und Werte in Datendateien, Kommandozeilen-Argumente und Programmausgaben. Das gilt für alles Neue.
- **Deutsch:** die Abstimmung mit Jan, `docs/concept.md`, `docs/backlog.md`, diese Datei und Commit-Nachrichten.

## Aufbau

- `src/logic/`: Spiellogik ohne Rendering. Muss headless laufen.
  - `GameState`: der zentrale Spielspeicher (Welt und Zelle der Figur, Fakten, Änderungen an Objekten je Welt, Gegenstände, Notizen). Reine Daten, speicherbar.
  - `World`: eine Welt aus ihrer Datei (heile Fassung), über die die Änderungen aus dem Spielspeicher gelegt werden. Ihre Objekte sind `WorldObject`.
  - `Session`: das laufende Spiel. Alles, was die Figur tut, läuft über `enter()`, `interact()` und `linger()`. Dort stehen auch alle Bedingungen und Folgen, die Regeln in Welt-Dateien benutzen dürfen. `interact()` wirkt nur von einer Zelle aus, von der das Objekt erreichbar ist (`can_use()`).
  - `RuleCheck`: liest alle Regeln, Fehler und Startfolgen und meldet, was `Session` nicht versteht (unbekannte Schlüssel, Namen von Welten, Objekten, Fehlern, Notizen, Fakten und Gegenständen, die es nicht gibt). Wer `Session` eine neue Bedingung oder Folge beibringt, trägt sie auch hier ein.
  - `Solver`: spielt das ganze Spiel in allen Varianten durch und meldet Sackgassen. Zustände, die sich nur in etwas unterscheiden, wonach keine Regel fragt, zählen als gleich.
  - `Settings`: was der Spieler für das ganze Spiel eingestellt hat (Lautstärke der Musik, Sprache), in `user://settings.json`. Getrennt vom Spielstand, damit es ein neues Spiel überdauert.
  - `SaveFile`: schreibt und liest den Spielstand. Ein unlesbarer Stand wird als `save.json.unusable` beiseitegelegt, nicht überschrieben.
  - `Mood`, `Iso`: Stimmungsregler und Umrechnung zwischen Zelle und Bildpunkt.
- `src/view/`: alles Sichtbare, Shader in `src/view/shaders/`. Die Hauptszene `scenes/game.tscn` baut ihre Knoten per Code auf.
  - `game.gd`: verbindet Session, Eingabe und Ansicht und entscheidet, was wann passiert (Laufen, Verweilen, Weltwechsel, Stimmung, Speichern). Ein Weltwechsel ist eine kurze Blende, eine Fahrt (`"by"`) oder eine Szene (`"as"`, bisher nur `quake`, der Riss).
  - `Stage`: eine Welt auf dem Bildschirm (Boden, Wasser, Schatten, `ObjectView` je Objekt (ohne Bild als gezeichneter Platzhalter), `Player`, die durchscheinende Erinnerung). Wird bei jedem Weltwechsel neu gebaut.
  - `Music`: spielt das Stück der Welt und blendet über. Der Bus „Music“ mit dem Dämpfungsfilter steht in `default_bus_layout.tres`, die Schleife in den Import-Einstellungen der Stücke.
  - `Sprites`: liest `data/sprites.json` und hält, was alle Ansichten teilen (Materialien, Lichtflecken, Treffer-Masken). Gehört dem laufenden Spiel und wird an jede Ansicht übergeben; es gibt keinen statischen Zustand in der Ansicht.
  - `Banner`: ein Schriftzug, der für seltene Momente kurz erscheint, etwa wenn eine Welt heil wird (`Session` meldet das als Folge `{"whole": welt}`).
  - `PauseView`: der Pause-Knopf oben links und die Pause-Seite (Lautstärke, Sprache, neu beginnen). Solange sie offen ist, steht der ganze Baum still (`get_tree().paused`); nur sie selbst und die Musik laufen weiter. Die Zurück-Geste des Handys öffnet sie, eine zweite verlässt das Spiel.
  - `RoundButton`: der runde Knopf in einer Bildschirmecke (dunkle Scheibe mit hellem Rand), den Pause und Notizbuch teilen. Sein Bild zeichnet, wem er gehört.
  - `DialogueBox`, `NotebookView`, `PauseView`, `StartScreen`: Oberfläche aus echten Controls. Was offen ist, deckt den Bildschirm mit einem Control ab, das alle Tipps schluckt. Flächen reagieren auf die Berührung des ersten Fingers, Knöpfe sind `Button`. Aussehen (Schriftgrößen, Farben, Flächen) kommt aus `assets/ui/theme.tres`; die Ansichten nennen nur die Variante (`theme_type_variation`).
  - Wind, Wasser und Schatten lesen ihre Richtung aus globalen Shader-Werten (`[shader_globals]` in `project.godot`), die `game.gd` aus der Stimmung setzt.
- `data/game.json`: Startwelt, Liste aller Welten, was beim Start eines neuen Spiels passiert und wann das Spiel zu Ende ist (`complete_if`).
- `data/worlds/`: Welten als JSON. Der Boden ist ein Zeichenraster (` ` Leere, `.` Gras, `=` Weg, `~` Wasser, `#` Brücke, `_` Boden eines Innenraums). `objects` beschreibt die heile Fassung, `broken` die Abweichungen der kaputten, `faults` die Fehler (jeder stellt bestimmte Stimmungsregler wieder her), `memories` die Orte der Erinnerung (jeder nennt den Ausschnitt der Welt, der dort durchscheint), `rules` was bei Interaktionen, beim Betreten von Zellen und beim Verweilen passiert.
- `data/sprites.json`: wie jedes Bild in der Welt sitzt (Breite, Fußpunkt, Schatten, Licht) und die Maße, die Spiel und Bildwerkzeuge teilen (Rand, Laufbilder). Die Schlüssel sind in `src/view/sprites.gd` beschrieben.
- `data/notes.json`: alle Einträge des Notizbuchs mit Art, Welt und Verknüpfungen (immer in beide Richtungen).
- `data/texts/`: alle sichtbaren Texte je Sprache (`en.json`, `de.json`), mit denselben Schlüsseln in jeder Datei. Regeln nennen nur Schlüssel.
- `assets/`: Bilder, Musik und Geräusche, die das Spiel lädt (`objects/`, `worlds/`, `music/`, `sounds/`), dazu das Theme der Oberfläche (`ui/theme.tres`, erzeugt von `tools/build_theme.gd`).
- `tools/`: Python-Skripte für Bild- und Musikgenerierung, eigene Umgebung in `tools/.venv` (Pakete in `tools/requirements.txt`). Die Stilvorgabe für alle Bild-Prompts steht in `tools/style.py`. `world_images.py <welt>` (Bodenbild einer Außenwelt), `village_images.py`, `bridge_image.py`, `room_images.py`, `fragment_images.py`, `valley_images.py` und `walk_images.py` erzeugen die Rohbilder (jede Datei höchstens einmal), `crop_sprites.py` schneidet sie zu und legt sie nach `assets/`. Wie ein Bild in der Welt sitzt (Breite, Fußpunkt), steht in `data/sprites.json`. `quake_sound.py` errechnet das Grollen des Risses aus Rauschen (kostet nichts, braucht keine Pakete).
- `styletest/`: generierte Rohbilder und Testmusik, von Godot ignoriert.

## Befehle

Godot liegt unter `C:\godot\godot.exe` (4.7.2). Nach neuen Skripten mit `class_name` oder neuen Assets zuerst importieren.

```powershell
& "C:\godot\godot.exe" --headless --path . --import
& "C:\godot\godot.exe" --headless --path . --script tests/test_logic.gd
& "C:\godot\godot.exe" --path . -- --tap=11,9 --tap=16,9 --wait=3 --screenshot=C:/path/image.png
& "C:\godot\godot.exe" --headless --path . --script tools/build_theme.gd
```

Der dritte Befehl startet das Spiel im Fenster, tippt nacheinander auf die Zellen, speichert ein Bildschirmfoto und gibt die Zelle der Figur, die offenen Fehler und den Stand der Musik aus (`src/view/test_helper.gd`). Ein Tipp auf ein Objekt mit Regel benutzt es. `--touch=x,y` tippt auf einen Punkt des Bildschirms (in Pixeln der Basisauflösung 1920x1080), etwa auf den Notizbuch-Knopf, den Pause-Knopf (82,82) oder durch einen Dialog; `--swipe=x1,y1,x2,y2` wischt mit dem Finger von einem Punkt zum anderen; `--back` macht, was die Zurück-Geste des Handys macht; mit `--mouse` kommen alle Tipps von der Maus statt vom Finger. Mit `--intact` startet die Welt in der heilen Fassung. Alle Argumente stehen in `src/view/test_helper.gd` und wirken nur in Debug-Bauten. Dort wechselt vorläufig auch die Taste F zwischen heil und kaputt, die Taste N beginnt ein neues Spiel. Der Spielstand liegt in `user://save.json` (`%APPDATA%\Godot\app_userdata\Everwild`); Läufe mit Argumenten laden und speichern nur mit `--save=Pfad`, die Einstellungen nur mit `--settings=Pfad`. Headless kann Godot nicht rendern, für Bildschirmfotos braucht es das Fenster.

Der vierte Befehl schreibt das Theme neu, nachdem `tools/build_theme.gd` geändert wurde.

Der Test prüft auch die Regeln aller Welten (`RuleCheck`) und die Lösbarkeit und spielt das Kapitel einmal so durch, wie es gedacht ist: Nach jeder Änderung an Welten oder Regeln laufen lassen. Er braucht etwa eine halbe Minute, fast alles davon für die Lösbarkeit. Beim Start im Fenster meldet ein Debug-Bau dieselben Regelfehler in der Ausgabe.

Aufs Handy (USB-Debugging an, per USB verbunden):

```powershell
& "C:\godot\godot.exe" --headless --path . --export-debug "Android" build/everwild.apk
adb install -r build\everwild.apk
adb shell monkey -p org.everwild.dev -c android.intent.category.LAUNCHER 1
adb logcat -d -s godot:*
```

Die Export-Vorlagen von Godot 4.7.2 liegen in `%APPDATA%\Godot\export_templates`, SDK, Java und Debug-Schlüssel stehen in Godots Editor-Einstellungen. Die Paket-ID `org.everwild.dev` ist nur für Testbauten.

Bild- und Musikgenerierung kostet Geld: nur auf ausdrückliche Anweisung von Jan und nur in der genannten Menge.

## Regeln

Die wichtigsten Regeln aus dem Konzept:

- Claude übernimmt die gesamte kreative Arbeit (Welten, Story, Grafik, Musik, Code, Tests). Jan entscheidet über Richtung und Geschmack und beurteilt, was Claude nicht kann: Spielgefühl, Touch und alles Hörbare.
- Jeder sichtbare Unterschied zwischen zwei Varianten einer Welt ist Absicht. Der Untergrund bleibt pixelgleich, Unterschiede entstehen nur über gezielt gesetzte Objekte, Shader und Verhalten.
- Kein Zustand darf unlösbar sein. Lösbarkeit wird automatisch geprüft.
- Spiellogik bleibt vom Rendering getrennt und deterministisch. Welten, Dialoge und Rätsel sind Daten.
