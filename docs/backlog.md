# Backlog

Alles, was noch zu bauen oder zu klären ist. Entscheidungen zum Spiel selbst stehen in `concept.md`, hier steht nur die Arbeit.

Die Reihenfolge innerhalb eines Abschnitts ist die vorgeschlagene Reihenfolge der Umsetzung. Erledigtes wird gelöscht, nicht abgehakt (die Historie steht in Git).

## Fundament

Spielspeicher, Regeln je Welt, Stimmung aus dem Zustand, Lösbarkeitsprüfung und lokale Speicherung stehen. Es fehlt:

1. **Speicherung in Google Play.** Spielstand über Google Play Games (Saved Games) sichern und zwischen Geräten abgleichen, mit Regel für Konflikte zwischen lokalem und entferntem Stand.
2. **Alte Spielstände nach Änderungen am Inhalt.** Ein Stand mit anderer Formatversion wird beiseitegelegt und das Spiel beginnt neu; eine Umwandlung alter Stände gibt es noch nicht. Ändert sich eine Welt, liegen alte Abweichungen ungeprüft über der neuen Fassung (nur verschwundene Welten und Objekte fallen weg). Braucht vor dem ersten Bau für andere Spieler eine Inhaltsversion und eine Regel, was mit einem Stand aus einer älteren Fassung geschieht.
3. **Strengere Prüfung des Codes.** Regeln, Folgen und Bedingungen sind weiterhin untypisierte Dictionaries (geprüft von `RuleCheck`). Offen sind strengere GDScript-Warnungen in `project.godot`, ein Formatierer oder Linter (gdtoolkit) und ein Testlauf, der vor jedem Commit von selbst startet.
4. **Kapiteldatei prüfen lassen.** Die Blöcke in `docs/chapters/valley.md` liest noch kein Werkzeug. Gedacht ist eines, das sie durchspielt (keine Sackgasse, jeder Hinweis rechtzeitig, kein Schritt überspringbar, Spielzeit) und mit den Regeln der Weltdateien vergleicht. Bis dahin müssen Datei und Welten von Hand übereinstimmen.
5. **Lösbarkeitsprüfung beschleunigen.** Sie braucht für das Tal etwa eine halbe Minute (knapp 7000 Zustände) und läuft bei jedem Test mit. Wächst der Inhalt, braucht sie einen eigenen Lauf oder eine Suche, die unabhängige Schritte nicht in jeder Reihenfolge durchgeht.
6. **Weltdateien werden von Hand gepflegt.** Die Dateien des Tals sind einmalig aus einem Skript entstanden und stehen deshalb mit einer Regel je Zeile da. Ein Werkzeug, das sie aus der Kapiteldatei erzeugt, gibt es nicht.

## Spielinhalt

### Das Tal

Das erste Kapitel (`docs/chapters/valley.md`) ist von Anfang bis Ende spielbar: der Abend vor dem Riss, Dorf, Mühlenhügel, Quelle, Weiher, Warte. Jan hat die Probefassung mit Platzhaltern für gut befunden; seitdem hat es eigene Bilder und Musik.

1. **Jans Urteil einholen.** Vor allem: Trägt die Geschichte, sind die Rätsel zu leicht oder zu undurchsichtig, dauert es lang genug? Die offenen Punkte stehen am Ende der Kapiteldatei.
2. **Was Jan nach dem ersten Durchspielen der alten Fassung bemängelt hat, am Tal prüfen:**
   - Wissen gehört zu Figuren (jeder Hinweis nennt in der Kapiteldatei, wer ihn glaubhaft geben kann).
   - Kein Überspringen von Schritten, die für die Geschichte zählen. Bekannte Lücken: Die Frau am Bach muss man nie ansprechen, und die Wetterfahne lässt sich ohne Erinnerung durchprobieren.
   - Figuren reagieren genau auf den Zustand, auch auf Teilzustände.
   - Figuren verwirrter und mysteriöser, Hinweise nicht als Anweisung.
   - Mehr Widerstand, das Notizbuch soll nötig sein.
3. **Bilder und Musik des Tals beurteilen.** Zwei Bodenbilder, vierzehn Objektbilder und zwei Musikstücke sind generiert und eingebaut. Jan beurteilt Stil und Klang. Die Maße der neuen Bilder (`data/sprites.json`) sind nach Augenmaß gesetzt. Die Spieluhr hat noch keinen Klang.
4. **Niedriges Wasser sichtbar machen.** Der trockene Bach im Dorf und der fast leere Weiher sehen aus wie Wasser, das falsch fließt. Dass der Stand sinkt, zeigen nur die Trittsteine und die Texte.
5. **Der Riss als Szene (Jan).** Er ist bisher ein Text über der Blende, wenn der Spieler aus der Tür tritt. Gewünscht: Der Bildschirm wackelt, dazu ein Geräusch, das Bild wird dunkel, dann langsam heller, und die Figur liegt in der kaputten Welt.
6. **Neubeginn sichtbar machen (Jan).** Nach „Neu beginnen“ steht die Figur im Haus des Alten. Wer vorher schon dort stand, sieht fast dasselbe Bild und hält den Knopf für kaputt. Braucht eine Blende oder ein anderes Zeichen, dass ein neues Spiel läuft.
7. **Man bleibt oft stecken (Jan, erstes Anspielen).** Bisher hing es an drei Stellen, die behoben sind: Ein Stein rollte hinter einen Baum, der Platz des Müllers war nicht zu finden (jetzt gilt überall: neben die Figur stellen und warten), und der Alte gab die Kurbel nur über den Schrank heraus, nicht im Gespräch. Offen bleibt das Muster dahinter:
   - Nichts in der Welt zeigt, wo man verweilen kann und dass gerade etwas geschieht, solange man wartet.
   - Jeder Schritt muss über alles gehen, was ein Spieler naheliegend versucht (die Figur ansprechen statt das Ding antippen und umgekehrt).
   - Sagt eine Figur zweimal dasselbe, obwohl der Spieler inzwischen mehr weiß, wirkt das wie eine Sackgasse.
   - Jan hat das Dorf erst mit Erklärung gelöst. Das zweite Antippen der Steine und der Windschatten erklären sich nicht von selbst.
8. **Sonderfälle in der Ansicht.** Das Notizbuch auf dem Tisch, das ferne Licht am Weiher und die Zeichnungen für Objekte ohne Bild stehen als Sonderfälle je Objektart in `ObjectView`.

### Weitere Punkte

1. **Laufanimation abstimmen.** Die Figur hat je Ansicht (vorn, hinten, jeweils auch gespiegelt) ein Standbild und vier Schritt-Bilder aus einem generierten Bogen (`tools/walk_images.py`). Offen ist, ob vier Bilder flüssig genug wirken, ob Tempo (7 Bilder je Sekunde) und Schrittweite zusammenpassen und ob der Schatten mitlaufen soll (er zeigt immer das Standbild). NPCs stehen still.
2. **Antworten zur Auswahl.** Figuren sprechen, der Spieler antwortet nie. Falls gewünscht, braucht der Dialog Auswahl.
3. **Notizbuch ausbauen.** Das Notizbuch sammelt Erinnerungen, Weltstücke, Hinweise und Bruchstücke über den Riss (`data/notes.json`) und zeigt zu jedem Eintrag, womit er zusammenhängt. Noch nicht gefundene Verwandte erscheinen als Lücke. Es fehlt eine Darstellung der Beziehungen als Bild (Karte der Weltstücke statt Liste) und die Gestaltung im gemalten Stil.
4. **Verweilen abstimmen.** Das Kind am Abhang führt es ein, vier weitere Orte nutzen es. Offen ist das Gefühl: Wartezeit (3,5 s), wie langsam die Erinnerung kommt (3 s), wie deutlich sie sein darf, wie weit sich die Musik neigt und ob sie ein eigenes Geräusch bekommt. Bisher zeigt nichts in der Welt, wo man stehen muss; das sagen nur die Figuren.
5. **Der Moment „Welt ist heil“ abstimmen.** Wird der letzte Fehler einer Welt behoben, erscheint ihr Name als Schriftzug, warmes Licht schwillt über das Bild und das Notizbuch zeigt je Weltstück einen Punkt pro Fehler. Offen ist das Gefühl: Stärke und Dauer des Lichts, Wortlaut, ob der Moment einen Klang bekommt und ob er warten soll, bis ein offener Dialog zu Ende ist. Das Ende des Kapitels hat noch keinen eigenen Moment.
6. **Rückmeldung bei Interaktionen.** Man sieht bisher nicht, was sich benutzen lässt und ob ein Tipp etwas bewirkt hat. Offen ist, wie deutlich das sein darf, ohne das Entdecken zu verderben.
7. **Geführte Szenen (Idee von Jan, erst einmal Nebensache).** Abschnitte, in denen das Spiel dem Spieler die Steuerung abnimmt: eine Zwischenszene, ein Stück Weg, auf dem die Figur von selbst einer anderen folgt, oder ein Rückblick. Dafür fehlt alles: Figuren, die laufen können (NPCs stehen bisher still), eine Abfolge von Schritten als Daten (gehe dorthin, sag das, warte, blende), die Sperre der Eingabe währenddessen und eine Regel, wie sich eine Szene überspringen lässt. Ein Rückblick könnte die heile Fassung einer Welt zeigen, die es als Daten schon gibt. Ein erstes Stück gibt es: Ein Ortswechsel wartet, bis ausgesprochen ist, was davor gesagt wird, und kann eine Fahrt sein (die Figur und andere gleiten an Bord eines Objekts hinüber, wie im Boot der Fischerin). Die Fahrt ist sehr schlicht: Die Figuren stehen vor dem Boot statt darin, und es fährt in gerader Linie.

## Rahmen

1. **Titelbildschirm.** Der Startbildschirm mit dem Hinweis auf Kopfhörer steht und erscheint nur beim allerersten Start; die Pause-Seite mit Lautstärke, Sprache und „Neu beginnen“ steht auch. Es fehlt ein Titel, sobald der Name feststeht.
2. **Pause-Seite ergänzen.** Ein Regler für Geräusche kommt dazu, sobald es welche gibt. Wird die Sprache gewechselt, während ein Dialog offen ist, bleiben dessen schon begonnene Zeilen in der alten Sprache.
3. **Android weiter prüfen.** Der Testbau läuft auf Jans Handy einwandfrei, auch die Oberfläche aus Controls, die Pause-Seite und die Zurück-Geste. Offen sind noch das App-Symbol und andere Bildschirmformate: Die Knöpfe in den Ecken sitzen fest 36 Pixel vom Rand und beachten den sicheren Bereich des Bildschirms (Kamera-Aussparung, runde Ecken) nicht.
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
- Umfang der ersten Fassung: wie viele Kapitel.
