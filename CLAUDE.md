# Everwild

Ruhiges, isometrisches Explorations-Puzzle für Mobile, gebaut mit Godot 4.

Alle Entscheidungen zu Spieldesign, Stil, Technik und Arbeitsteilung stehen in `docs/concept.md`. Vor jeder Arbeit lesen und bei neuen Entscheidungen aktualisieren.

Was noch zu bauen ist, steht in `docs/backlog.md`. Erledigtes dort löschen, Neues eintragen.

Wie Spielinhalte entstehen (Bausteine, Regeln für Rätsel, Figuren und Welten, Ablauf, Prüflisten), steht in `docs/toolbox.md`. Bisher ein Entwurf, den Jan noch nicht durchgesehen hat. Wer ein Kapitel entwirft oder ändert, prüft es dagegen.

Der Spielinhalt steht je Kapitel in `docs/chapters/` (bisher `valley.md`): Geschichte, Orte, Figuren, Rätsel und Zusammenhänge, als Text und als feste Blöcke. Wer Welten, Regeln oder Texte eines Kapitels ändert, ändert auch seine Datei.

## Sprache

- **Englisch:** der gesamte Quellcode (GDScript, Shader, Python), Bezeichner, Kommentare, Datei- und Ordnernamen, Schlüssel und Werte in Datendateien, Kommandozeilen-Argumente und Programmausgaben. Das gilt für alles Neue.
- **Deutsch:** die Abstimmung mit Jan, `docs/concept.md`, `docs/backlog.md`, diese Datei und Commit-Nachrichten.

## Aufbau

- `src/logic/`: Spiellogik ohne Rendering. Muss headless laufen.
  - `GameState`: der zentrale Spielspeicher (Welt und Zelle der Figur, Fakten, Änderungen an Objekten je Welt, Gegenstände und was man je hatte, Notizen). Reine Daten, speicherbar.
  - `World`: eine Welt aus ihrer Datei (heile Fassung), über die die Änderungen aus dem Spielspeicher gelegt werden. Ihre Objekte sind `WorldObject`.
  - `Session`: das laufende Spiel. Alles, was die Figur tut, läuft über `enter()`, `interact()` und `linger()`, das Denken im Notizbuch über `combine()` (zwei Notizen ergeben eine Einsicht). Dort stehen auch alle Bedingungen und Folgen, die Regeln in Welt-Dateien benutzen dürfen. `interact()` wirkt nur von einer Zelle aus, von der das Objekt erreichbar ist (`can_use()`).
  - `RuleCheck`: liest alle Regeln, Fehler und Startfolgen und meldet, was `Session` nicht versteht (unbekannte Schlüssel, Namen von Welten, Objekten, Fehlern, Notizen, Fakten und Gegenständen, die es nicht gibt). Wer `Session` eine neue Bedingung oder Folge beibringt, trägt sie auch hier ein.
  - `Solver`: spielt das ganze Spiel in allen Varianten durch, auch das Denken, und meldet Sackgassen. Zustände, die sich nur in etwas unterscheiden, wonach keine Regel fragt, zählen als gleich.
  - `Notebook`: liest `data/notes.json` und weiß, welche zwei Notizen welche Einsicht ergeben.
  - `Settings`: was der Spieler für das ganze Spiel eingestellt hat (Lautstärke von Musik und Klängen, Sprache), in `user://settings.json`. Getrennt vom Spielstand, damit es ein neues Spiel überdauert.
  - `SaveFile`: schreibt und liest den Spielstand. Ein unlesbarer Stand wird als `save.json.unusable` beiseitegelegt, nicht überschrieben.
  - `Mood`, `Iso`: Stimmungsregler und Umrechnung zwischen Zelle und Bildpunkt.
- `src/view/`: alles Sichtbare, Shader in `src/view/shaders/`. Die Hauptszene `scenes/game.tscn` baut ihre Knoten per Code auf.
  - `game.gd`: verbindet Session, Eingabe und Ansicht und entscheidet, was wann passiert (Laufen, Verweilen, Hinweise, Weltwechsel, Szenen, Stimmung, Speichern). Ein Weltwechsel ist eine kurze Blende, eine Fahrt (`"by"`) oder eine Szene (`"as"`, bisher nur `quake`, der Riss).
  - `Cutscene`: spielt eine Szene aus `data/scenes.json` (Folge `{"scene": id}` einer Regel). Figuren gehen, die Kamera folgt, eine andere Welt wird gezeigt.
  - `FigureLife`: lässt Figuren atmen, sich umdrehen, beim Sprechen wippen und auf ihren Abendwegen (`stroll`) gehen. Nur Ansicht; für die Spiellogik bleiben sie auf ihrer Zelle.
  - `MemorySpots`, `HintView`, `FarLight`: der Schimmer an Verweil-Stellen, der tippende Finger der Hinweise im Prolog, ein fernes Licht in einer Szene.
  - `Sounds`: spielt Klänge und Brabbelstimmen auf dem Bus „Sounds“.
  - `Stage`: eine Welt auf dem Bildschirm (Boden, Wasser, Schatten, `ObjectView` je Objekt (ohne Bild als gezeichneter Platzhalter), `Player`, die durchscheinende Erinnerung). Wird bei jedem Weltwechsel neu gebaut.
  - `WindView`: der sichtbare Wind einer Welt, feine Streifen in Richtung und Stärke der Stimmung. Hinter hohen Dingen (Heuwagen, Haus, Mühle) liegt ihr Windschatten ohne Streifen.
  - `Music`: spielt das Stück der Welt und blendet über. Der Bus „Music“ mit dem Dämpfungsfilter steht in `default_bus_layout.tres`, die Schleife in den Import-Einstellungen der Stücke.
  - `Sprites`: liest `data/sprites.json` und hält, was alle Ansichten teilen (Materialien, Lichtflecken, Treffer-Masken). Gehört dem laufenden Spiel und wird an jede Ansicht übergeben; es gibt keinen statischen Zustand in der Ansicht.
  - `PauseView`: der Pause-Knopf oben links und die Pause-Seite (Lautstärke, Sprache, neu beginnen). Solange sie offen ist, steht der ganze Baum still (`get_tree().paused`); nur sie selbst und die Musik laufen weiter. Die Zurück-Geste des Handys öffnet sie, eine zweite verlässt das Spiel.
  - `RoundButton`: der runde Knopf in einer Bildschirmecke (dunkle Scheibe mit hellem Rand), den Pause und Notizbuch teilen. Sein Bild zeichnet, wem er gehört.
  - `DialogueBox` zeigt neben dem Namen eine blasse Randnotiz, wenn die Figur etwas einsteckt oder abgibt (Folgen `give` und `take` vor einem `say`). Die Namen der Dinge stehen als `item.<id>` in den Texten.
  - `DialogueBox`, `NotebookView`, `PauseView`, `StartScreen`: Oberfläche aus echten Controls. Was offen ist, deckt den Bildschirm mit einem Control ab, das alle Tipps schluckt. Flächen reagieren auf die Berührung des ersten Fingers, Knöpfe sind `Button`. Aussehen (Schriftgrößen, Farben, Flächen) kommt aus `assets/ui/theme.tres`; die Ansichten nennen nur die Variante (`theme_type_variation`).
  - `NotebookView` ist ein aufgeschlagenes Buch: links `MapView` (die Karte aus `data/map.json`), rechts die Notizen als `NoteCard`, acht je Seite. Ziehen, Ablegen, Zusammenziehen und Blättern wertet es selbst in `_input` aus.
  - `DialogueBox` meldet den Beginn jeder Zeile (Signal `line_begun`); `Sounds` spielt dann einen Laut des Sprechers, falls er welche hat.
  - Wind, Wasser und Schatten lesen ihre Richtung aus globalen Shader-Werten (`[shader_globals]` in `project.godot`), die `game.gd` aus der Stimmung setzt. Dasselbe gilt für den Wasserstand: `WaterView` legt bei gesunkenem Stand das Bett frei, vom Ufer nach innen.
- `data/game.json`: Startwelt, Liste aller Welten, was beim Start eines neuen Spiels passiert und wann das Spiel zu Ende ist (`complete_if`).
- `data/scenes.json`: die Szenen, je eine Liste von Schritten (beschrieben in `src/view/cutscene.gd`).
- `data/map.json`: wo die Weltstücke auf der Karte im Notizbuch liegen und wann welcher Pfeil zu sehen ist.
- `data/worlds/`: Welten als JSON. Der Boden ist ein Zeichenraster (` ` Leere, `.` Gras, `=` Weg, `~` Wasser, `#` Brücke, `_` Boden eines Innenraums). `objects` beschreibt die heile Fassung (Objekte stehen auf festem Boden; Brücke, Floß und Trittsteine liegen auf `#`, Stufen stehen im Wasser), `broken` die Abweichungen der kaputten, `faults` die Fehler (jeder stellt bestimmte Stimmungsregler wieder her), `memories` die Orte der Erinnerung (jeder nennt den Ausschnitt der Welt, der dort durchscheint, und mit `without` Objekte, die dort nie durchscheinen), `rules` was bei Interaktionen, beim Betreten von Zellen und beim Verweilen passiert, `whole_says` was jemand sagt, wenn der Spieler zum ersten Mal im heilen Stück steht (`Session` meldet das Heilwerden als Folge `{"whole": welt}`), `hints` worauf im Prolog ein Finger zeigt, `music_if` ein anderes Stück, solange Bedingungen gelten (die Spieluhr). Ein Objekt kann mit `stroll` einen Abendweg haben.
- `data/sprites.json`: wie jedes Bild in der Welt sitzt (Breite, Fußpunkt, Schatten, Licht) und die Maße, die Spiel und Bildwerkzeuge teilen (Rand, Laufbilder). Die Schlüssel sind in `src/view/sprites.gd` beschrieben.
- `data/notes.json`: alle Einträge des Notizbuchs mit Art, Welt und Verknüpfungen (immer in beide Richtungen). Eine Einsicht nennt mit `from` die zwei Notizen, aus denen sie entsteht; `crossed_if` streicht eine Notiz durch.
- `data/texts/`: alle sichtbaren Texte je Sprache (`en.json`, `de.json`), mit denselben Schlüsseln in jeder Datei. Regeln nennen nur Schlüssel.
- `assets/`: Bilder, Musik und Geräusche, die das Spiel lädt (`objects/`, `worlds/`, `music/`, `sounds/`), dazu das Theme der Oberfläche (`ui/theme.tres`, erzeugt von `tools/build_theme.gd`), die Seite des Notizbuchs (`ui/notebook.png`) und die Handschrift (`fonts/Caveat.ttf`, SIL Open Font License).
- `tools/`: Python-Skripte für Bild- und Musikgenerierung, eigene Umgebung in `tools/.venv` (Pakete in `tools/requirements.txt`). Die Stilvorgabe für alle Bild-Prompts steht in `tools/style.py`. `world_images.py <welt>` (Bodenbild einer Außenwelt), `village_images.py`, `bridge_image.py`, `room_images.py`, `fragment_images.py`, `valley_images.py` und `walk_images.py` (Laufbögen je Figur und Ansicht, etwa `old_man_back`) und `notebook_images.py` (die Buchseite) erzeugen die Rohbilder (jede Datei höchstens einmal), `crop_sprites.py` schneidet sie zu und legt sie nach `assets/`. Wie ein Bild in der Welt sitzt (Breite, Fußpunkt), steht in `data/sprites.json`. `quake_sound.py` errechnet das Grollen des Risses aus Rauschen, `sound_effects.py` die übrigen Klänge und die Spieluhr (beide kosten nichts und brauchen keine Pakete). `voice_sounds.py <figur>` lässt wortlose Laute einer Figur generieren (kostet wenig, nur auf Anweisung) und schneidet sie zu. `app_icon.py` setzt das App-Symbol aus vorhandenen Bildern zusammen und legt es nach `assets/icon/` (kostet ebenfalls nichts).
- `styletest/`: generierte Rohbilder und Testmusik, von Godot ignoriert.

## Befehle

Godot liegt unter `C:\godot\godot.exe` (4.7.2). Nach neuen Skripten mit `class_name` oder neuen Assets zuerst importieren.

```powershell
& "C:\godot\godot.exe" --headless --path . --import
& "C:\godot\godot.exe" --headless --path . --script tests/test_logic.gd
& "C:\godot\godot.exe" --path . -- --tap=11,9 --tap=16,9 --wait=3 --screenshot=C:/path/image.png
& "C:\godot\godot.exe" --headless --path . --script tools/build_theme.gd
```

Der dritte Befehl startet das Spiel im Fenster, tippt nacheinander auf die Zellen, speichert ein Bildschirmfoto und gibt die Zelle der Figur, die offenen Fehler und den Stand der Musik aus (`src/view/test_helper.gd`). Ein Tipp auf ein Objekt mit Regel benutzt es. `--touch=x,y` tippt auf einen Punkt des Bildschirms (in Pixeln der Basisauflösung 1920x1080), etwa auf den Notizbuch-Knopf, den Pause-Knopf (82,82) oder durch einen Dialog; `--swipe=x1,y1,x2,y2` wischt mit dem Finger von einem Punkt zum anderen (auch zum Ziehen von Zetteln im Notizbuch); `--hold=s` wartet zusätzlich, `--shot=Pfad` macht zwischendurch ein Bildschirmfoto; `--back` macht, was die Zurück-Geste des Handys macht; mit `--mouse` kommen alle Tipps von der Maus statt vom Finger. Mit `--intact` startet die Welt in der heilen Fassung. Alle Argumente stehen in `src/view/test_helper.gd` und wirken nur in Debug-Bauten. Dort wechselt vorläufig auch die Taste F zwischen heil und kaputt, die Taste N beginnt ein neues Spiel. Der Spielstand liegt in `user://save.json` (`%APPDATA%\Godot\app_userdata\Everwild`); Läufe mit Argumenten laden und speichern nur mit `--save=Pfad`, die Einstellungen nur mit `--settings=Pfad`. Headless kann Godot nicht rendern, für Bildschirmfotos braucht es das Fenster.

Der vierte Befehl schreibt das Theme neu, nachdem `tools/build_theme.gd` geändert wurde.

Der Test prüft auch die Regeln aller Welten (`RuleCheck`) und die Lösbarkeit und spielt das Kapitel einmal so durch, wie es gedacht ist: Nach jeder Änderung an Welten oder Regeln laufen lassen. Er braucht gut eine Minute, fast alles davon für die Lösbarkeit. Beim Start im Fenster meldet ein Debug-Bau dieselben Regelfehler in der Ausgabe.

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
