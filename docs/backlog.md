# Backlog

Alles, was noch zu bauen oder zu klären ist. Entscheidungen zum Spiel selbst stehen in `concept.md`, hier steht nur die Arbeit.

Die Reihenfolge innerhalb eines Abschnitts ist die vorgeschlagene Reihenfolge der Umsetzung. Erledigtes wird gelöscht, nicht abgehakt (die Historie steht in Git).

## Fundament

Spielspeicher, Regeln je Welt, Stimmung aus dem Zustand, Lösbarkeitsprüfung und lokale Speicherung stehen. Es fehlt:

1. **Speicherung in Google Play.** Spielstand über Google Play Games (Saved Games) sichern und zwischen Geräten abgleichen, mit Regel für Konflikte zwischen lokalem und entferntem Stand.
2. **Alte Spielstände nach Änderungen am Inhalt.** Ein Stand mit anderer Formatversion wird beiseitegelegt und das Spiel beginnt neu; eine Umwandlung alter Stände gibt es noch nicht. Ändert sich eine Welt, liegen alte Abweichungen ungeprüft über der neuen Fassung (nur verschwundene Welten und Objekte fallen weg). Braucht vor dem ersten Bau für andere Spieler eine Inhaltsversion und eine Regel, was mit einem Stand aus einer älteren Fassung geschieht.
3. **Strengere Prüfung des Codes.** Regeln, Folgen und Bedingungen sind weiterhin untypisierte Dictionaries (geprüft von `RuleCheck`). Offen sind strengere GDScript-Warnungen in `project.godot`, ein Formatierer oder Linter (gdtoolkit) und ein Testlauf, der vor jedem Commit von selbst startet.
4. **Sonderfälle je Objektart in der Ansicht.** Das Notizbuch auf dem Tisch und die Platzhalter-Zeichnungen stehen noch als Sonderfälle in `ObjectView`.
5. **Tests der Geschichte.** `_test_story` und `_test_village_game` hängen an festen Zellen und Textschlüsseln und müssen mit der Überarbeitung der Geschichte neu geschrieben werden.

## Spielinhalt

### Rückmeldung von Jan nach dem ersten Durchspielen auf dem Handy

Insgesamt ist der Ablauf zu schnell, zu simpel und zu vorhersehbar. Im Einzelnen:

- **Wissen gehört zu Figuren.** Wer etwas weiß, muss dazu passen. Dass die Kurbel im Schrank liegt, kann nur der alte Mann wissen (oder das Notizbuch), nicht der Müller. Jeden Hinweis darauf prüfen, wer ihn glaubhaft geben kann.
- **Widerspruch bei den Laternen.** Die Frau schickt den Spieler zum alten Mann, weil der zu den Laternen Rat wissen soll. Man muss die Laternen aber anzünden, um überhaupt zu ihm zu kommen. Reihenfolge und Begründung neu ordnen.
- **Kein Überspringen.** Schritte lassen sich auslassen (zum Beispiel die Kurbel holen, ohne mit dem alten Mann gesprochen zu haben). Die Regeln müssen die gedachte Reihenfolge strenger erzwingen, wo sie für die Geschichte zählt.
- **Klar erkennbar, wann eine Welt heil ist.** Man kann die Mühle in Gang setzen und erst danach ihre Laterne anzünden. Es ist oft nicht offensichtlich, ob eine Welt fertig ist. Braucht einen deutlichen Moment, wenn der letzte Fehler einer Welt behoben ist, und eine sichtbare Anzeige des Zustands (im Notizbuch oder in der Welt selbst).
- **NPCs reagieren strenger auf den Zustand.** Was eine Figur sagt, muss genau zu dem passen, was schon getan ist und was noch fehlt, auch bei Teilzuständen.
- **Figuren verwirrter und mysteriöser.** Weniger Auskunft, mehr Andeutung. Es fehlen Denkpausen, Satzfetzen, Abschweifungen und Dinge, die nichts zur Lösung beitragen. Hinweise sollen sich nicht wie Anweisungen lesen.
- **Mehr Widerstand.** Rätsel brauchen mehr als einen Schritt und Momente, in denen man selbst kombinieren muss. Das Notizbuch soll dafür nötig werden.

### Weitere Punkte

1. **Laufanimation abstimmen.** Die Figur hat je Ansicht (vorn, hinten, jeweils auch gespiegelt) ein Standbild und vier Schritt-Bilder aus einem generierten Bogen (`tools/walk_images.py`). Offen ist, ob vier Bilder flüssig genug wirken, ob Tempo (7 Bilder je Sekunde) und Schrittweite zusammenpassen und ob der Schatten mitlaufen soll (er zeigt immer das Standbild). NPCs stehen still.
2. **NPCs und Dialoge ausbauen.** Figuren sind Objekte der Welt, was sie sagen, hängt über Regeln am Spielstand, die Texte stehen je Sprache in `data/texts/`. Es gibt drei Figuren (alter Mann im Haus, Frau am Bach, Müller), die den Spieler leiten. Es fehlen die eigentlichen Figuren und Texte der Geschichte und, falls gewünscht, Antworten zur Auswahl.
3. **Weitere Welten.** Der Wechsel zwischen Welten steht (Türen und Portale sind Regeln mit einem Ziel, das vom Zustand abhängt, dazwischen eine Blende). Es gibt das Dorf mit dem Raum im Haus, den Mühlenhügel und die Quelle, jeweils mit eigenem Musikstück, verbunden durch Steinbögen und mit Abhängigkeiten untereinander. Es fehlen weitere Weltstücke, mehr Fehler je Welt (das Konzept will vier bis sechs, es sind zwei bis drei) und Portale, die man erst finden muss.
4. **Notizbuch ausbauen.** Das Notizbuch sammelt Erinnerungen, Weltstücke und Hinweise (`data/notes.json`) und zeigt zu jedem Eintrag, womit er zusammenhängt. Noch nicht gefundene Verwandte erscheinen als Lücke. Es fehlt eine Darstellung der Beziehungen als Bild (Karte der Weltstücke statt Liste) und die Gestaltung im gemalten Stil.
5. **Verweilen einschränken und in die Geschichte einbetten.** Bisher scheint die Erinnerung überall nach 3,5 Sekunden Stillstand durch. Das ist zu stark und kommt zu früh (Jan). Neu:
   - Die Erinnerung zeigt sich nur an bestimmten Orten, die in der Weltdatei stehen, und erst, nachdem die Geschichte sie eingeführt hat.
   - Eine Figur führt sie ein: Sie steht am Abhang, erzählt, dass sie jeden Tag dort steht und sich manchmal an die Welt von früher zu erinnern meint. Stellt man sich daneben und wartet, scheint langsam die alte Welt durch. Figur, Ort und Text gehören in den neuen Entwurf des Dorfs.
   - Technisch: Das Durchscheinen wird eine Folge von Verweil-Regeln (die es mit `cells` und `zone` schon gibt) statt eines festen Verhaltens in `game.gd`. Ob ein Ort die ganze Welt zeigt oder nur einen Ausschnitt, ist offen.
   - Weiter offen ist das Gefühl: Wartezeit, wie langsam die Erinnerung kommt, wie deutlich sie sein darf und ob sie ein eigenes Geräusch bekommt.
6. **Tutorial-Dorf als fertiger Abschnitt.** Heile Fassung mit den Aufgaben für den alten Mann, der Bruch, das Aufwachen, die kaputte Fassung mit vier bis sechs Fehlern. Die drei Fehler, die das Dorf jetzt hat (Stein vor der Brücke, Stein im Osten mit gespiegeltem Baum, dunkle Laternen), sind nur ein Probelauf für die Mechanik, und das Spiel beginnt vorläufig direkt im kaputten Dorf.
7. **Rückmeldung bei Interaktionen.** Man sieht bisher nicht, was sich benutzen lässt und ob ein Tipp etwas bewirkt hat. Offen ist, wie deutlich das sein darf, ohne das Entdecken zu verderben.

## Rahmen

1. **Titelbildschirm.** Der Startbildschirm mit dem Hinweis auf Kopfhörer steht und erscheint nur beim allerersten Start; die Pause-Seite mit Lautstärke, Sprache und „Neu beginnen“ steht auch. Es fehlt ein Titel, sobald der Name feststeht.
2. **Pause-Seite abstimmen.** Auf dem Handy prüfen: Zurück-Geste (öffnet die Seite, die zweite verlässt das Spiel), Schieberegler mit dem Finger, Größe und Lage des Knopfes. Ein Regler für Geräusche kommt dazu, sobald es welche gibt. Wird die Sprache gewechselt, während ein Dialog offen ist, bleiben dessen schon begonnene Zeilen in der alten Sprache.
3. **Android weiter prüfen.** Offen sind noch das App-Symbol und ein Blick auf Schriftgrößen und Ränder bei anderen Bildschirmformaten. Der Notizbuch-Knopf sitzt fest 36 Pixel vom Rand und beachtet den sicheren Bereich des Bildschirms (Kamera-Aussparung, runde Ecken) nicht. Nach dem Umbau der Oberfläche auf Controls müssen Dialog, Notizbuch und Startbildschirm einmal auf dem Handy durchgetippt werden; geprüft sind sie bisher nur im Fenster mit nachgestellten Fingertipps.
4. **Renderer vergleichen.** Das Spiel läuft mit „mobile“ (Vulkan). Für reines 2D auf Android ist „compatibility“ üblicher. Einmal auf dem Handy nebeneinander ansehen.

## Grafik und Ton

2. **Dialogfeld und Notizbuch.** Beide nutzen die Standardschrift von Godot und schlichte Flächen. Brauchen eine Schrift und Gestaltung, die zum gemalten Stil passen.
3. **Raum einrichten.** Der Raum hat gemalten Boden und Wände, einen Tisch und einen Schrank. Für Rätsel im Haus fehlen Dinge, mit denen man etwas tun kann.
4. **Verdeckung durch hohe Objekte.** Häuser und Bäume verdecken die Figur und Wege. Braucht eine Lösung (durchscheinen, Umriss oder Regeln für die Platzierung).
5. **Bodenbilder einpassen.** Das Bildmodell hält sich nicht immer genau an den Plan (der Raum kam 3 % größer und etwas höher heraus). Bisher wird die Lage von Hand an den gemalten Ecken ausgerichtet. Bei mehr Welten lohnt ein Schritt im Werkzeug, der das selbst misst.
6. **Schatten auf Höhenunterschieden.** Der Schatten der Laterne fällt über Brücke und Bach, als wäre alles flach.
7. **Gespiegelte Objekte.** Das gemalte Licht sitzt nach dem Spiegeln auf der falschen Seite. Für die heile Welt eigene Varianten statt Spiegelung, die Spiegelung bleibt den falschen Welten vorbehalten.
8. **Geräusche.** Schritte je Untergrund, Wasser, Wind, Interaktionen.
9. **Musik in Schichten.** Stücke je Welt, die sich mit der Reparatur schrittweise zusammensetzen, statt nur Tonhöhe und Filter zu ändern. Modellwahl und Lizenz sind noch offen.

## Zu klären

- Name: „Everwild“ ist durch Rare belegt und bleibt Arbeitstitel. Ein eigener Name muss stehen, bevor der Eintrag im Play Store angelegt wird (die Paket-ID lässt sich danach nicht mehr ändern).
- Bleibt `.vscode/settings.json` im Repository?
- Soll die Figur stehen bleiben, wenn beim Betreten einer Zelle ein Dialog aufgeht? Bisher läuft sie weiter zum Ziel, während der Text erscheint.
- Umfang der ersten Fassung: wie viele Welten.
